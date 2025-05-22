FROM openeuler/openeuler:22.03 as BUILDER
RUN dnf update -y &&\
    dnf install -y curl gcc libpq-devel openssl-devel pkg-config postgresql-devel make cmake protobuf-compiler

ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
ENV HOME=/root
RUN mkdir -p $HOME/.cargo/
ADD /cargo_config $HOME/.cargo/config

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.78.0 -c rust-std -c rust-src

WORKDIR /src/mirrorlist-server

COPY . .

RUN source $HOME/.cargo/env && cargo build --release

FROM openeuler/openeuler:22.03
RUN dnf update -y

COPY --from=BUILDER /src/mirrorlist-server/start.sh /opt/app/start.sh
COPY --from=BUILDER /src/mirrorlist-server/config /opt/app/config
COPY --from=BUILDER /src/mirrorlist-server/target/release/mirrorlist-server /opt/app/mirrorlist-server
COPY --from=BUILDER /src/mirrorlist-server/target/release/generate-mirrorlist-cache /opt/app/generate-mirrorlist-cache
RUN dnf install -y libpq-devel

ENTRYPOINT ["/opt/app/start.sh"]
