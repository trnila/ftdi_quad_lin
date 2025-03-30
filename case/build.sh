#!/usr/bin/env bash
set -ex
NAME="ftdi_quad_lin_openscad"

cat <<EOF | docker build --progress=plain -t "$NAME" - 
FROM openscad/openscad:2021.01
RUN apt update && apt install -y \
	curl \
	git \
	python \
	codespell \
	build-essential \
	pkg-config \
	libpng-dev

RUN git clone --depth 1 --branch 7.1.1-47 https://github.com/ImageMagick/ImageMagick.git /tmp/imagemagick \
	&& cd /tmp/imagemagick \
	&& ./configure \
	&& make -j $(nproc) \
	&& make install \
	&& rm -rf /tmp/imagemagick
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

RUN git clone --depth 1 -b v21.38.0 https://github.com/nophead/NopSCADlib /opt/openscad/libraries/NopSCADlib/
ENV OPENSCADPATH=/opt/openscad/libraries

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="/usr/local/bin" sh
ENV UV_PYTHON_INSTALL_DIR=/opt/python
RUN cd /opt/openscad/libraries/NopSCADlib/scripts \
	&& uv init \
	&& uv add \
		colorama==0.4.6 \
		markdown==3.8
EOF

docker run \
	-v /tmp:/tmp \
	-v "$PWD:/case/" \
	-w /case \
	-e DISPLAY \
	-u "$(id -u):$(id -g)" \
	"$NAME" \
	uv run --no-cache --project /opt/openscad/libraries/NopSCADlib/scripts /opt/openscad/libraries/NopSCADlib/scripts/make_all.py
