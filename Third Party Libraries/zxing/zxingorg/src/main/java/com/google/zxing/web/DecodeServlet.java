/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.zxing.web;

import com.google.common.collect.Lists;
import com.google.common.io.Resources;
import com.google.common.net.HttpHeaders;
import com.google.common.net.MediaType;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.DecodeHintType;
import com.google.zxing.FormatException;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.NotFoundException;
import com.google.zxing.Reader;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.client.j2se.ImageReader;
import com.google.zxing.common.GlobalHistogramBinarizer;
import com.google.zxing.common.HybridBinarizer;

import com.google.zxing.multi.GenericMultipleBarcodeReader;
import com.google.zxing.multi.MultipleBarcodeReader;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.FileCleanerCleanup;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileCleaningTracker;

import java.awt.color.CMMException;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.imageio.ImageIO;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * {@link HttpServlet} which decodes images containing barcodes. Given a URL, it will
 * retrieve the image and decode it. It can also process image files uploaded via POST.
 *
 * @author Sean Owen
 */
public final class DecodeServlet extends HttpServlet {

  private static final Logger log = Logger.getLogger(DecodeServlet.class.getName());

  // No real reason to let people upload more than a 10MB image
  private static final long MAX_IMAGE_SIZE = 10_000_000L;
  // No real reason to deal with more than maybe 10 megapixels
  private static final int MAX_PIXELS = 10_000_000;
  private static final byte[] REMAINDER_BUFFER = new byte[32768];
  private static final Map<DecodeHintType,Object> HINTS;
  private static final Map<DecodeHintType,Object> HINTS_PURE;

  static {
    HINTS = new EnumMap<>(DecodeHintType.class);
    HINTS.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
    HINTS.put(DecodeHintType.POSSIBLE_FORMATS, EnumSet.allOf(BarcodeFormat.class));
    HINTS_PURE = new EnumMap<>(HINTS);
    HINTS_PURE.put(DecodeHintType.PURE_BARCODE, Boolean.TRUE);
  }

  private DiskFileItemFactory diskFileItemFactory;
  private Iterable<String> blockedURLSubstrings;

  @Override
  public void init(ServletConfig servletConfig) throws ServletException {
    Logger logger = Logger.getLogger("com.google.zxing");
    ServletContext context = servletConfig.getServletContext();
    logger.addHandler(new ServletContextLogHandler(context));
    File repository = (File) context.getAttribute("javax.servlet.context.tempdir");
    FileCleaningTracker fileCleaningTracker = FileCleanerCleanup.getFileCleaningTracker(context);
    diskFileItemFactory = new DiskFileItemFactory(1 << 16, repository);
    diskFileItemFactory.setFileCleaningTracker(fileCleaningTracker);

    URL blockURL = context.getClassLoader().getResource("/private/uri-block-substrings.txt");
    if (blockURL == null) {
      blockedURLSubstrings = Collections.emptyList();
    } else {
      try {
        blockedURLSubstrings = Resources.readLines(blockURL, StandardCharsets.UTF_8);
      } catch (IOException ioe) {
        throw new ServletException(ioe);
      }
      log.info("Blocking URIs containing: " + blockedURLSubstrings);
    }
  }

  @Override
  protected void doGet(HttpServletRequest request,
                       HttpServletResponse response) throws ServletException, IOException {

    String imageURIString = request.getParameter("u");
    if (imageURIString == null || imageURIString.isEmpty()) {
      log.info("URI was empty");
      response.sendRedirect("badurl.jspx");
      return;
    }

    imageURIString = imageURIString.trim();
    for (CharSequence substring : blockedURLSubstrings) {
      if (imageURIString.contains(substring)) {
        log.info("Disallowed URI " + imageURIString);        
        response.sendRedirect("badurl.jspx");
        return;
      }
    }

    URI imageURI;
    try {
      imageURI = new URI(imageURIString);
      // Assume http: if not specified
      if (imageURI.getScheme() == null) {
        imageURI = new URI("http://" + imageURIString);
      }
    } catch (URISyntaxException urise) {
      log.info("URI " + imageURIString + " was not valid: " + urise);
      response.sendRedirect("badurl.jspx");
      return;
    }
    
    // Shortcut for data URI
    if ("data".equals(imageURI.getScheme())) {
      try {
        BufferedImage image = ImageReader.readDataURIImage(imageURI);
        processImage(image, request, response);
      } catch (IOException ioe) {
        log.info(ioe.toString());
        response.sendRedirect("badurl.jspx");
      }
      return;
    }
    
    URL imageURL;    
    try {
      imageURL = imageURI.toURL();
    } catch (MalformedURLException ignored) {
      log.info("URI was not valid: " + imageURIString);
      response.sendRedirect("badurl.jspx");
      return;
    }

    String protocol = imageURL.getProtocol();
    if (!"http".equalsIgnoreCase(protocol) && !"https".equalsIgnoreCase(protocol)) {
      log.info("URI was not valid: " + imageURIString);
      response.sendRedirect("badurl.jspx");
      return;
    }

    HttpURLConnection connection;
    try {
      connection = (HttpURLConnection) imageURL.openConnection();
    } catch (IllegalArgumentException ignored) {
      log.info("URI could not be opened: " + imageURL);
      response.sendRedirect("badurl.jspx");
      return;
    }

    connection.setAllowUserInteraction(false);
    connection.setReadTimeout(5000);
    connection.setConnectTimeout(5000);
    connection.setRequestProperty(HttpHeaders.USER_AGENT, "zxing.org");
    connection.setRequestProperty(HttpHeaders.CONNECTION, "close");

    try {
      connection.connect();
    } catch (IOException ioe) {
      // Encompasses lots of stuff, including
      //  java.net.SocketException, java.net.UnknownHostException,
      //  javax.net.ssl.SSLPeerUnverifiedException,
      //  org.apache.http.NoHttpResponseException,
      //  org.apache.http.client.ClientProtocolException,
      log.info(ioe.toString());
      response.sendRedirect("badurl.jspx");
      return;
    }

    try (InputStream is = connection.getInputStream()) {
      try {
        if (connection.getResponseCode() != HttpServletResponse.SC_OK) {
          log.info("Unsuccessful return code: " + connection.getResponseCode());
          response.sendRedirect("badurl.jspx");
          return;
        }
        if (connection.getHeaderFieldInt(HttpHeaders.CONTENT_LENGTH, 0) > MAX_IMAGE_SIZE) {
          log.info("Too large");
          response.sendRedirect("badimage.jspx");
          return;
        }

        log.info("Decoding " + imageURL);
        processStream(is, request, response);
      } finally {
        consumeRemainder(is);
      }
    } catch (IOException ioe) {
      log.info(ioe.toString());
      response.sendRedirect("badurl.jspx");
    } finally {
      connection.disconnect();
    }

  }

  private static void consumeRemainder(InputStream is) {
    try {
      int available;
      while ((available = is.available()) > 0) {
        is.read(REMAINDER_BUFFER, 0, available); // don't care about value, or collision
      }
    } catch (IOException | IndexOutOfBoundsException ioe) {
      // sun.net.www.http.ChunkedInputStream.read is throwing IndexOutOfBoundsException
      // continue
    }
  }

  @Override
  protected void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {

    if (!ServletFileUpload.isMultipartContent(request)) {
      log.info("File upload was not multipart");
      response.sendRedirect("badimage.jspx");
      return;
    }

    ServletFileUpload upload = new ServletFileUpload(diskFileItemFactory);
    upload.setFileSizeMax(MAX_IMAGE_SIZE);

    // Parse the request
    try {
      for (FileItem item : upload.parseRequest(request)) {
        if (!item.isFormField()) {
          if (item.getSize() <= MAX_IMAGE_SIZE) {
            log.info("Decoding uploaded file");
            try (InputStream is = item.getInputStream()) {
              processStream(is, request, response);
            }
          } else {
            log.info("Too large");
            response.sendRedirect("badimage.jspx");
          }
          break;
        }
      }
    } catch (FileUploadException fue) {
      log.info(fue.toString());
      response.sendRedirect("badimage.jspx");
    }

  }

  private static void processStream(InputStream is,
                                    ServletRequest request,
                                    HttpServletResponse response) throws ServletException, IOException {

    BufferedImage image;
    try {
      image = ImageIO.read(is);
    } catch (IOException | CMMException | IllegalArgumentException ioe) {
      log.info(ioe.toString());
      // Have seen these in some logs
      response.sendRedirect("badimage.jspx");
      return;
    }
    if (image == null) {
      response.sendRedirect("badimage.jspx");
      return;
    }
    if (image.getHeight() <= 1 || image.getWidth() <= 1 ||
        image.getHeight() * image.getWidth() > MAX_PIXELS) {
      log.info("Dimensions out of bounds: " + image.getWidth() + 'x' + image.getHeight());
      response.sendRedirect("badimage.jspx");
      return;
    }
    
    processImage(image, request, response);
  }
  
  private static void processImage(BufferedImage image,
                                   ServletRequest request,
                                   HttpServletResponse response) throws IOException, ServletException {

    LuminanceSource source = new BufferedImageLuminanceSource(image);
    BinaryBitmap bitmap = new BinaryBitmap(new GlobalHistogramBinarizer(source));
    Collection<Result> results = Lists.newArrayListWithCapacity(1);

    try {

      Reader reader = new MultiFormatReader();
      ReaderException savedException = null;
      try {
        // Look for multiple barcodes
        MultipleBarcodeReader multiReader = new GenericMultipleBarcodeReader(reader);
        Result[] theResults = multiReader.decodeMultiple(bitmap, HINTS);
        if (theResults != null) {
          results.addAll(Arrays.asList(theResults));
        }
      } catch (ReaderException re) {
        savedException = re;
      }
  
      if (results.isEmpty()) {
        try {
          // Look for pure barcode
          Result theResult = reader.decode(bitmap, HINTS_PURE);
          if (theResult != null) {
            results.add(theResult);
          }
        } catch (ReaderException re) {
          savedException = re;
        }
      }
  
      if (results.isEmpty()) {
        try {
          // Look for normal barcode in photo
          Result theResult = reader.decode(bitmap, HINTS);
          if (theResult != null) {
            results.add(theResult);
          }
        } catch (ReaderException re) {
          savedException = re;
        }
      }
  
      if (results.isEmpty()) {
        try {
          // Try again with other binarizer
          BinaryBitmap hybridBitmap = new BinaryBitmap(new HybridBinarizer(source));
          Result theResult = reader.decode(hybridBitmap, HINTS);
          if (theResult != null) {
            results.add(theResult);
          }
        } catch (ReaderException re) {
          savedException = re;
        }
      }
  
      if (results.isEmpty()) {
        handleException(savedException, response);
        return;
      }

    } catch (RuntimeException re) {
      // Call out unexpected errors in the log clearly
      log.log(Level.WARNING, "Unexpected exception from library", re);
      throw new ServletException(re);
    }

    String fullParameter = request.getParameter("full");
    boolean minimalOutput = fullParameter != null && !Boolean.parseBoolean(fullParameter);
    if (minimalOutput) {
      response.setContentType(MediaType.PLAIN_TEXT_UTF_8.toString());
      response.setCharacterEncoding(StandardCharsets.UTF_8.name());
      try (Writer out = new OutputStreamWriter(response.getOutputStream(), StandardCharsets.UTF_8)) {
        for (Result result : results) {
          out.write(result.getText());
          out.write('\n');
        }
      }
    } else {
      request.setAttribute("results", results);
      request.getRequestDispatcher("decoderesult.jspx").forward(request, response);
    }
  }

  private static void handleException(ReaderException re, HttpServletResponse response) throws IOException {
    if (re instanceof NotFoundException) {
      log.info("Not found: " + re);
      response.sendRedirect("notfound.jspx");
    } else if (re instanceof FormatException) {
      log.info("Format problem: " + re);
      response.sendRedirect("format.jspx");
    } else if (re instanceof ChecksumException) {
      log.info("Checksum problem: " + re);
      response.sendRedirect("format.jspx");
    } else {
      log.info("Unknown problem: " + re);
      response.sendRedirect("notfound.jspx");
    }
  }

}
