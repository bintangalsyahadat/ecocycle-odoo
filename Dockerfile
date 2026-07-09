FROM odoo:18.0

# Increment this to bust Docker cache on Railway
ARG CACHEBUST=6

USER root
RUN echo "Cache bust: ${CACHEBUST}"

# Clone addons repo at build time (no submodule dependency on Railway)
# CACHEBUST ensures fresh clone when addons repo is updated
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && echo "Cloning addons (cachebust=${CACHEBUST})" \
    && git clone --depth 1 https://github.com/bintangalsyahadat/ecocycle-odoo-addons.git /mnt/extra-addons \
    && apt-get purge -y git && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Remove Debian-installed typing_extensions & wrapt — they block pip upgrades
# (must delete manually: apt remove would cascade-break Odoo's .deb deps)
RUN rm -rf /usr/lib/python3/dist-packages/typing_extensions* \
        /usr/lib/python3/dist-packages/wrapt*

# Install addons Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements.txt \
    && pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements-fastapi.txt

COPY --chown=root:root ./odoo.conf /etc/odoo/

# Strip any stale ${PYTHON_SITE} (safety cleanup)
RUN sed -i 's|,/${PYTHON_SITE}/odoo/addons||g' /etc/odoo/odoo.conf

# Fix volume permissions at runtime (Railway mounts volumes as root)
RUN echo '#!/bin/bash' > /fix-perms.sh \
    && echo 'chown -R odoo:odoo /var/lib/odoo 2>/dev/null || true' >> /fix-perms.sh \
    && chmod +x /fix-perms.sh

# Keep running as root so Odoo entrypoint can chown data dir, then drop to odoo user
USER root
ENTRYPOINT ["/bin/bash", "-c", "/fix-perms.sh && exec /entrypoint.sh odoo"]
