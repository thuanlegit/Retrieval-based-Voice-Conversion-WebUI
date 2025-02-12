#!/bin/sh

# Set up environment
echo "Setting up environment..."

uv venv --python 3.9
uv pip install pip==24.0
uv pip install huggingface_hub[cli]
source .venv/bin/activate.fish

echo "Environment setup complete."

# Install requirements
echo "Installing requirements..."

pip install torch==2.4 torchvision torchaudio
pip install -r requirements.txt
python tools/download_models.py

echo "Requirements installed."

# Download models
echo "Downloading models..."


# Check if the user is logged in to Hugging Face
if [ -z "$(huggingface-cli whoami 2>/dev/null)" ]; then
    echo "You are not logged in to Hugging Face. Please log in."
    huggingface-cli login
fi

# List of models and their respective folders
MODELS="added_IVF886_Flat_nprobe_1_vixtts3_v2.index:./logs/vixtts3 rmvpe.pt:./ vixtts3.pth:./assets/weights"


# Download each model into its specified folder
for entry in $MODELS; do
    model=$(echo "$entry" | cut -d':' -f1)
    folder=$(echo "$entry" | cut -d':' -f2)
    mkdir -p "$folder"
    echo "Downloading $model into $folder..."
    huggingface-cli download ryanix/rvc_vie "$model" --local-dir "$folder" --local-dir-use-symlinks False
done

echo "Models downloaded."