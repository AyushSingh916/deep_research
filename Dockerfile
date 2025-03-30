# Use slim Python image as base
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Set environment variables for API keys
ENV HUGGINGFACE_TOKEN="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"
ENV serp_api_key="39de6ee154a641a07eab3f85efb116fd7eee2983bd6ba45b3c9a1e8c874c9490"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download the model
RUN mkdir -p /root/deepresearch_models/bart-large-cnn && \
    python -c "from transformers import AutoTokenizer, AutoModelForSeq2SeqLM; \
    tokenizer = AutoTokenizer.from_pretrained('facebook/bart-large-cnn', use_auth_token='${HUGGINGFACE_TOKEN}'); \
    model = AutoModelForSeq2SeqLM.from_pretrained('facebook/bart-large-cnn', use_auth_token='${HUGGINGFACE_TOKEN}'); \
    tokenizer.save_pretrained('/root/deepresearch_models/bart-large-cnn'); \
    model.save_pretrained('/root/deepresearch_models/bart-large-cnn')"

# Copy application code
COPY . .

# Expose port for Streamlit
EXPOSE 8501

# Command to run the application
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]