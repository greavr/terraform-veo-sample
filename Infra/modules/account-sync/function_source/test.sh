#!/bin/bash
export DELEGATED_ADMIN_EMAIL="admin@rgreaves.altostrat.com"
export GROUP_MAPPING='{"bake-off-admins@rgreaves.altostrat.com":"veo-colab-nyc","vpc-test@rgreaves.altostrat.com":"veo-colab-seo","vpc-test@rgreaves.altostrat.com":"veo-colab-tor"}'

python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
python3 main.py