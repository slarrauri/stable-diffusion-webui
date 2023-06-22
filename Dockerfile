FROM nvidia/cuda:11.8.0-base-ubuntu22.04

ARG VERSION
ENV VERSION=1.3.2

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update -y \
 && apt-get -qq install -y --no-install-recommends \
    git git-lfs libgl1 pkg-config python-is-python3 python3-dev python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' user
RUN mkdir /app && chown -R user:user /app
WORKDIR /app
USER user

RUN git clone --depth 1 --branch v${VERSION} -c advice.detachedHead=false \
    https://github.com/slarrauri/stable-diffusion-webui.git /app

ENV PIP_NO_CACHE_DIR=true
ENV PIP_ROOT_USER_ACTION=ignore
RUN sed -i -e 's/    start()/    #start()/g' /app/launch.py \
 && python launch.py --skip-torch-cuda-test \
 && sed -i -e 's/    #start()/    start()/g' /app/launch.py

ADD --chown=user https://huggingface.co/nitrosocke/Arcane-Diffusion/resolve/main/arcane-diffusion-v3.ckpt /app/data/models/Stable-diffusion/arcane-diffusion-v3.ckpt
ADD --chown=user https://huggingface.co/ckpt/anything-v4.5-vae-swapped/resolve/main/anything-v4.5-vae-swapped.safetensors /app/data/models/Stable-diffusion/anything-v4.5-vae-swapped.safetensors


EXPOSE 7860

ENTRYPOINT ["python", "launch.py", "--listen", "--data-dir", "/app/data", "--disable-console-progressbars", "--enable-insecure-extension-access"]
CMD ["--skip-torch-cuda-test", "--use-cpu all"]
