docker build --platform linux/amd64 -t to-pip .
docker tag to-pip gcr.io/falra-368206/to-pip:1.9.0
docker push gcr.io/falra-368206/to-pip:1.9.0
gcloud config set run/region us-central1
gcloud run deploy to-pip \
--image=gcr.io/falra-368206/to-pip:1.9.0 \
--allow-unauthenticated \
--port=8000 \
--service-account=1037695533427-compute@developer.gserviceaccount.com \
--concurrency=1 \
--cpu=0.08 \
--memory=128Mi \
--max-instances=1 \
--region=us-central1 \
--project=falra-368206
