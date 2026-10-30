FROM docker.io/library/python:slim

WORKDIR /app

ENV APP_PORT=8880 \
    FLASK_DEBUG=0 \
    WOL_BROADCAST_IP=10.10.2.255 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN python -m pip install --no-cache-dir -r requirements.txt

COPY webinterface.py devices.yml logging.yml ./
COPY templates/ ./templates/
COPY static/ ./static/

EXPOSE 8880

CMD ["python", "webinterface.py"]
