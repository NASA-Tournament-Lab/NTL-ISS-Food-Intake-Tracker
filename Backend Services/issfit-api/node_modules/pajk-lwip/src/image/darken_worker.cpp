#include "image.h"

DarkenWorker::DarkenWorker(
    float ld,
    CImg<unsigned char> * cimg,
    Nan::Callback * callback
): Nan::AsyncWorker(callback), _ld(ld), _cimg(cimg) {}

DarkenWorker::~DarkenWorker() {}

void DarkenWorker::Execute () {
    if (_ld == 0) return;
    try {
        cimg_forXYZ(*_cimg, x, y, z) {
            unsigned char r = _cimg->atXYZC(x, y, z, 0),
                          g = _cimg->atXYZC(x, y, z, 1),
                          b = _cimg->atXYZC(x, y, z, 2),
                          a = _cimg->atXYZC(x, y, z, 3);

            float ratio = 1.0 - _ld;
            _cimg->fillC(x, y, z, r*ratio, g*ratio, b*ratio, a);
        }
    } catch (CImgException e) {
        SetErrorMessage(e.what());
        return;
    }
    return;
}

void DarkenWorker::HandleOKCallback () {
    Nan::HandleScope();
    Local<Value> argv[] = {
        Nan::Null()
    };
    callback->Call(1, argv);
}