// == mojo ====================================================================
//
//    Copyright (c) gnawice@gnawice.com. All rights reserved.
//	  See LICENSE in root folder
//
//    Permission is hereby granted, free of charge, to any person obtaining a
//    copy of this software and associated documentation files(the "Software"),
//    to deal in the Software without restriction, including without
//    limitation the rights to use, copy, modify, merge, publish, distribute,
//    sublicense, and/or sell copies of the Software, and to permit persons to
//    whom the Software is furnished to do so, subject to the following
//    conditions :
//
//    The above copyright notice and this permission notice shall be included
//    in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//    OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
//    THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// ============================================================================
//    util.h: various stuff- progress, html log, opencv
// ==================================================================== mojo ==

#ifndef _MOJO_UTIL_H_
#define _MOJO_UTIL_H_

#include <string>
#include "network.h"

#define int64 __foo1
#define uint64 __foo2
#include "opencv2/opencv.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgproc/types_c.h"
#undef int64
#undef uint64

namespace mojo {
// transforms image.
// x_center, y_center of input
// out dim is size of output w or h
// theta in degrees
cv::Mat matrix2cv(const mojo::matrix &m, bool uc8) {
    cv::Mat cv_m;
    if (m.chans != 3) {
        cv_m = cv::Mat(m.cols, m.rows, CV_32FC1, m.x);
    }
    if (m.chans == 3) {
        cv::Mat in[3];
        in[0] = cv::Mat(m.cols, m.rows, CV_32FC1, m.x);
        in[1] = cv::Mat(m.cols, m.rows, CV_32FC1, &m.x[m.cols * m.rows]);
        in[2] = cv::Mat(m.cols, m.rows, CV_32FC1, &m.x[2 * m.cols * m.rows]);
        cv::merge(in, 3, cv_m);
    }
    if (uc8) {
        double min_, max_;
        cv_m = cv_m.reshape(1);
        cv::minMaxIdx(cv_m, &min_, &max_);
        cv_m = cv_m - min_;
        max_ = max_ - min_;
        cv_m /= max_;
        cv_m *= 255;
        cv_m = cv_m.reshape(m.chans, m.rows);
        if (m.chans != 3)
            cv_m.convertTo(cv_m, CV_8UC1);
        else
            cv_m.convertTo(cv_m, CV_8UC3);
    }
    return cv_m;
}

mojo::matrix cv2matrix(cv::Mat &m) {
    if (m.type() == CV_8UC1) {
        m.convertTo(m, CV_32FC1);
        m = m / 255.;
    }
    if (m.type() == CV_8UC3) {
        m.convertTo(m, CV_32FC3);
    }
    if (m.type() == CV_32FC1) {
        return mojo::matrix(m.cols, m.rows, 1, (float *)m.data);
    }
    if (m.type() == CV_32FC3) {
        cv::Mat in[3];
        cv::split(m, in);
        mojo::matrix out(m.cols, m.rows, 3);
        memcpy(out.x, in[0].data, m.cols * m.rows * sizeof(float));
        memcpy(&out.x[m.cols * m.rows], in[1].data, m.cols * m.rows * sizeof(float));
        memcpy(&out.x[2 * m.cols * m.rows], in[2].data, m.cols * m.rows * sizeof(float));
        return out;
    }
    return mojo::matrix(0, 0, 0);
}
mojo::matrix transform(const mojo::matrix in, const int x_center, const int y_center, int out_dim, float theta,
                       float scale) {
    const double _pi = 3.14159265358979323846;
    float cos_theta = (float)std::cos(theta / 180. * _pi);
    float sin_theta = (float)std::sin(theta / 180. * _pi);
    float half_dim = 0.5f * (float)out_dim / scale;

    cv::Point2f pts1[4], pts2[4];
    pts1[0] = cv::Point2f(x_center - half_dim, y_center - half_dim);
    pts1[1] = cv::Point2f(x_center + half_dim, y_center - half_dim);
    pts1[2] = cv::Point2f(x_center + half_dim, y_center + half_dim);
    pts1[3] = cv::Point2f(x_center - half_dim, y_center + half_dim);

    pts2[0] = cv::Point2f(-half_dim, -half_dim);
    pts2[1] = cv::Point2f(half_dim, -half_dim);
    pts2[2] = cv::Point2f(half_dim, half_dim);
    pts2[3] = cv::Point2f(-half_dim, half_dim);

    // rotate around center spot
    for (int pt = 0; pt < 4; pt++) {
        float x_t = (pts2[pt].x) * scale;
        float y_t = (pts2[pt].y) * scale;
        float x = cos_theta * x_t - sin_theta * y_t;
        float y = sin_theta * x_t + cos_theta * y_t;

        pts2[pt].x = x + (float)x_center;
        pts2[pt].y = y + (float)y_center;
    }

    cv::Mat input = mojo::matrix2cv(in, false);

    cv::Mat M = cv::getPerspectiveTransform(pts1, pts2);
    cv::Mat cv_out;

    cv::warpPerspective(input, cv_out, cv::getPerspectiveTransform(pts1, pts2),
                        cv::Size((int)((float)out_dim), (int)((float)out_dim)), cv::INTER_AREA, cv::BORDER_REPLICATE);
    return mojo::cv2matrix(cv_out);
}

mojo::matrix bgr2ycrcb(mojo::matrix &m) {
    cv::Mat cv_m = matrix2cv(m, false);
    double min_, max_;
    cv_m = cv_m.reshape(1);
    cv::minMaxIdx(cv_m, &min_, &max_);
    cv_m = cv_m - min_;
    max_ = max_ - min_;
    cv_m /= max_;

    cv_m = cv_m.reshape(m.chans, m.rows);
    cv::Mat cv_Y;
    cv::cvtColor(cv_m, cv_Y, CV_BGR2YCrCb);
    cv_Y = cv_Y.reshape(1);
    cv_Y -= 0.5f;
    cv_Y *= 2.f;
    cv_Y = cv_Y.reshape(m.chans);

    m = cv2matrix(cv_Y);
    return m;
}

void save(mojo::matrix &m, std::string filename) {
    cv::Mat m2 = matrix2cv(m, true);
    cv::imwrite(filename, m2);
}

void show(const mojo::matrix &m, float zoom = 1.0f, const char *win_name = "", int wait_ms = 1) {
    if (m.cols <= 0 || m.rows <= 0 || m.chans <= 0)
        return;
    cv::Mat cv_m = matrix2cv(m, false);

    double min_, max_;
    cv_m = cv_m.reshape(1);
    cv::minMaxIdx(cv_m, &min_, &max_);
    cv_m = cv_m - min_;
    max_ = max_ - min_;
    cv_m /= max_;
    cv_m = cv_m.reshape(m.chans, m.rows);

    if (zoom != 1.f)
        cv::resize(cv_m, cv_m, cv::Size(0, 0), zoom, zoom, 0);
    cv::imshow(win_name, cv_m);
    cv::waitKey(wait_ms);
}

void hide(const char *win_name = "") {
    if (win_name == NULL)
        cv::destroyAllWindows();
    else
        cv::destroyWindow(win_name);
}

enum mojo_palette {
    gray = 0,
    hot = 1,
    tensorglow = 2,
    voodoo = 3,
    saltnpepa = 4
};

cv::Mat colorize(cv::Mat im, mojo::mojo_palette color_palette = mojo::gray) {

    if (im.cols <= 0 || im.rows <= 0)
        return im;

    cv::Mat RGB[3];
    RGB[0] = im.clone(); // blue
    RGB[1] = im.clone();
    RGB[2] = im.clone();

    for (int i = 0; i < im.rows * im.cols; i++) {
        unsigned char c = (unsigned char)im.data[i];
        // tensor flow colors (red black blue)
        if (color_palette == mojo::tensorglow) {
            if (c == 255) {
                RGB[2].data[i] = 255;
                RGB[1].data[i] = 255;
                RGB[0].data[i] = 255;
            } else if (c < 128) {
                RGB[2].data[i] = 0;
                RGB[1].data[i] = 0;
                RGB[0].data[i] = 2 * (127 - c);
            } else {
                RGB[2].data[i] = 2 * (c - 128);
                RGB[1].data[i] = 0;
                RGB[0].data[i] = 0;
            }
        } else if (color_palette == mojo::hot) {
            if (c == 255) {
                RGB[2].data[i] = 255;
                RGB[1].data[i] = 255;
                RGB[0].data[i] = 255;
            } else if (c < 128) {
                RGB[0].data[i] = 0;
                RGB[1].data[i] = 0;
                RGB[2].data[i] = c * 2;
            } else {
                RGB[0].data[i] = 0;
                RGB[1].data[i] = (c - 128) * 2;
                RGB[2].data[i] = 255;
            }
        } else if (color_palette == mojo::saltnpepa) {
            if (c == 255) {
                RGB[2].data[i] = 255;
                RGB[1].data[i] = 255;
                RGB[0].data[i] = 255;
            } else if (c & 1) {
                RGB[0].data[i] = 0;
                RGB[1].data[i] = 0;
                RGB[2].data[i] = 0;
            } else {
                RGB[0].data[i] = 255;
                RGB[1].data[i] = 255;
                RGB[2].data[i] = 255;
            }
        } else if (color_palette == mojo::voodoo) {
            if (c == 255) {
                RGB[2].data[i] = 255;
                RGB[1].data[i] = 255;
                RGB[0].data[i] = 255;
            } else if (c < 128) {
                RGB[2].data[i] = (127 - c);
                RGB[1].data[i] = 0;
                RGB[0].data[i] = 2 * (127 - c);
            } else {
                RGB[2].data[i] = (c - 128);
                RGB[1].data[i] = 2 * (c - 128);
                RGB[0].data[i] = 0;
            }
        }
    }

    cv::Mat out;
    cv::merge(RGB, 3, out);
    return out;
}

mojo::matrix draw_cnn_weights(mojo::network &cnn, int layer_index, mojo::mojo_palette color_palette = mojo::gray) {
    cv::Mat im;
    std::vector<cv::Mat> im_layers;

    int k = layer_index - 1;
    {
        base_layer *layer = cnn.layer_sets[k];

        for (int i = 0; i < (int)layer->forward_linked_layers.size(); i++) {
            std::pair<int, base_layer *> link = layer->forward_linked_layers[i];
            int connection_index = link.first;
            base_layer *p_bottom = link.second;
            if (!p_bottom->has_weights())
                continue;
            for (int i = 0; i < cnn.W[connection_index]->chans; i++) {
                cv::Mat im = matrix2cv(cnn.W[connection_index]->get_chans(i), true);
                cv::resize(im, im, cv::Size(0, 0), 2., 2., 0);
                im_layers.push_back(im);
            }
            // draw these nicely
            int s = im_layers[0].cols;
            cv::Mat tmp(layer->node.chans * (s + 1) + 1, p_bottom->node.chans * (s + 1) + 1, CV_8UC1);
            tmp = 255;
            for (int j = 0; j < layer->node.chans; j++) {
                for (int i = 0; i < p_bottom->node.chans; i++) {
                    // make colors go 0 to 254
                    double min, max;
                    int index = i + j * p_bottom->node.chans;
                    cv::minMaxIdx(im_layers[index], &min, &max);
                    im_layers[index] -= min;
                    im_layers[index] /= (max - min) / 254;

                    im_layers[index].convertTo(im_layers[index], CV_8UC1);
                    im_layers[index].copyTo(tmp(cv::Rect(i * s + 1 + i, j * s + 1 + j, s, s)));
                }
            }
            im = tmp;
        }
    }
    cv::Mat colorized = colorize(im, color_palette);
    return cv2matrix(colorized);
}

mojo::matrix draw_cnn_weights(mojo::network &cnn, std::string layer_name,
                              mojo::mojo_palette color_palette = mojo::gray) {
    int layer_index = cnn.layer_map[layer_name];
    return draw_cnn_weights(cnn, layer_index, color_palette);
}

mojo::matrix draw_cnn_state(mojo::network &cnn, int layer_index, mojo::mojo_palette color_palette = mojo::gray) {
    cv::Mat im;
    int layers = (int)cnn.layer_sets.size();
    if (layer_index < 0 || layer_index >= layers)
        return mojo::matrix();

    std::vector<cv::Mat> im_layers;
    base_layer *layer = cnn.layer_sets[layer_index];

    for (int i = 0; i < layer->node.chans; i++) {
        cv::Mat im = matrix2cv(layer->node.get_chans(i), true);
        cv::resize(im, im, cv::Size(0, 0), 2., 2., 0);
        im_layers.push_back(im);
    }
    // draw these nicely
    int s = im_layers[0].cols;
    cv::Mat tmp(s + 2, (int)im_layers.size() * (1 + s) + 1, CV_8UC1);
    tmp = 255;
    for (int i = 0; i < (int)im_layers.size(); i++) {
        // make colors go 0 to 254
        double min, max;
        cv::minMaxIdx(im_layers[i], &min, &max);
        im_layers[i] -= min;
        im_layers[i] /= (max - min) / 254;

        im_layers[i].convertTo(im_layers[i], CV_8UC1);
        im_layers[i].copyTo(tmp(cv::Rect(i * s + 1 + i, 1, s, s)));
    }
    im = tmp;

    cv::Mat colorized = colorize(im, color_palette);
    return cv2matrix(colorized);
}

mojo::matrix draw_cnn_state(mojo::network &cnn, std::string layer_name, mojo::mojo_palette color_palette = mojo::gray) {
    int layer_index = cnn.layer_map[layer_name];
    return draw_cnn_state(cnn, layer_index, color_palette);
}

} // namespace

#endif // _MOJO_UTIL_H_
