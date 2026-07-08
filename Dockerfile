FROM odoo:18.0

USER root

# Clone addons repo at build time (no submodule dependency on Railway)
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && git clone --depth 1 https://github.com/bintangalsyahadat/ecocycle-odoo-addons.git /mnt/extra-addons \
    && apt-get purge -y git && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Install addons Python dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements.txt \
    && pip3 install --no-cache-dir --break-system-packages -r /mnt/extra-addons/requirements-fastapi.txt

# Copy Odoo config and inject pip-installed OCA addons path
COPY ./odoo.conf /etc/odoo/
RUN PYTHON_SITE=$(python3 -c "import site; print(site.getsitepackages()[0])") \
    && sed -i "s|^addons_path = .*|&,\${PYTHON_SITE}/odoo/addons|" /etc/odoo/odoo.conf

USER odoo
