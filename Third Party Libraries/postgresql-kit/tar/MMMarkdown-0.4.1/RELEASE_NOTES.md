# MMMarkdown Release Notes

## 0.4.1
Fix an exception when whitespace preceded what would otherwise be a header ([#47](https://github.com/mdiep/MMMarkdown/issues/47)).

## 0.4
This release adds support for GitHub-flavored Markdown and extensions. It also includes bug fixes, updated Xcode project settings, and more modernization. 

## 0.3
This release adds an HTML parser, which is needed to properly handle HTML inside Markdown. It also removes the precompiled libraries in favor of including the project.

Other changes include:

 - Support newer iOS architectures
 - Fix a crash when passed an empty string
 - Fix code spans with multiple backticks
 - Fix code spans that contain newlines
 - Fix handling of images with no alt text
 - Annotate that the markdown can't be nil
 - Fix behavior of archive builds
 - Update Xcode project settings
 - Modernize the code

## 0.2.3
Fix the iOS deployment target and static library to support iOS 5.0.

## 0.2.2
Updated the iOS static library to include armv7s architecture.

## 0.2.1
Bugfix release that fixes 2 issues:

 - Add support for alternate ASCII line endings (\r\n and \r)
 - Fix a crash when list items have leading spaces beyond their
   indentation level

## 0.2 - Correctness
This release focused on expanding the test suite and fixing bugs. Many bugs were fixed and support for the Markdown image syntax was added.

## 0.1
The initial release of MMMarkdown. Implemented enough of markdown to pass all of Gruber's tests.
