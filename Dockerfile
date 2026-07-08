FROM odoo:18.0

USER root

# Clone addons repo at build time (no submodule dependency on Railway)
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && git clone --depth 1 https://github.com/bintangalsyahadat/ecocycle-odoo-addons.git /mnt/extra-addons \
    && apt-get purge -y git && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Remove Debian-installed typing_extensions & wrapt — they block pip upgrades
# (must delete manually: apt remove would cascade-break Odoo's .deb deps)
RUN rm -rf /usr/lib/python3/dist-packages/typing_extensions* \
        /usr/lib/python3/dist-packages/wrapt*

# Install addons Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements.txt \
    && pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements-fastapi.txt

# Copy Odoo config
COPY ./odoo.conf /etc/odoo/

USER odoo
