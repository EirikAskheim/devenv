FROM cgr.dev/chainguard/git:latest as git
RUN git clone https://github.com/helix-editor/helix.git
#RUN rm -Rf /git/helix/.git

FROM cgr.dev/chainguard/rust:latest as build-helix
COPY --chown=nonroot:nonroot --from=git /home/git/helix /home/nonroot/helix
COPY bashrc /home/nonroot/.profile
WORKDIR /home/nonroot/helix
RUN cargo install --locked --path helix-term

FROM cgr.dev/chainguard/rust:latest as build-zellij
RUN cargo install --locked zellij

FROM debian:sid-slim
RUN useradd -ms /bin/bash nonroot
USER nonroot
COPY --chown=nonroot:nonroot config /home/nonroot/.config
COPY --chown=nonroot:nonroot --from=build-helix /home/nonroot/.cargo/bin/hx /home/nonroot/bin/hx
COPY --chown=nonroot:nonroot --from=build-helix /home/nonroot/helix/runtime /home/nonroot/.config/helix/runtime
#COPY --chown=nonroot:nonroot --from=build-zellij /home/nonroot/.cargo/bin/zellij /home/nonroot/bin/zellij
COPY --chown=nonroot:nonroot bashrc /home/nonroot/.bashrc
WORKDIR /home/nonroot
RUN	/home/nonroot/bin/hx --grammar fetch && \
	/home/nonroot/bin/hx --grammar build
ENTRYPOINT ["/home/nonroot/bin/hx"]

