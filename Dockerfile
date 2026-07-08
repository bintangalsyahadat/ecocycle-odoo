FROM odoo:18.0

USER root

# Install addons Python dependencies
COPY ./workdir/addons/requirements.txt /tmp/addons-requirements.txt
COPY ./workdir/addons/requirements-fastapi.txt /tmp/addons-fastapi-requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/addons-requirements.txt \
    && pip3 install --no-cache-dir -r /tmp/addons-fastapi-requirements.txt \
    && rm /tmp/addons-requirements.txt /tmp/addons-fastapi-requirements.txt

# Copy custom addons to extra-addons path
COPY ./workdir/addons /mnt/extra-addons

# Copy Odoo config
COPY ./odoo.conf /etc/odoo/

USER odoo
