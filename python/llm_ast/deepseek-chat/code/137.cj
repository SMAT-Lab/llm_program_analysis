import logging
import os
import uuid

import fastapi
from google.cloud import storage

import backend.server.v2.store.exceptions
from backend.util.settings import Settings

logger = logging.getLogger(__name__)

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/gif", "image/webp"}
ALLOWED_VIDEO_TYPES = {"video/mp4", "video/webm"}
MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB

async def check_media_exists(user_id: str, filename: str) -> str | None:
    """
    Check if a media file exists in storage for the given user.
    Tries both images and videos directories.

    Args:
        user_id (str): ID of the user who uploaded the file
        filename (str): Name of the file to check

    Returns:
        str | None: URL of the blob if it exists, None otherwise
    """
    try:
        settings = Settings()
        storage_client = storage.Client()
        bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)

        # Check images
        image_path = f"users/{user_id}/images/{filename}"
        image_blob = bucket.blob(image_path)
        if image_blob.exists():
            return image_blob.public_url

        # Check videos
        video_path = f"users/{user_id}/videos/{filename}"
        video_blob = bucket.blob(video_path)
        if video_blob.exists():
            return video_blob.public_url

        return None
    except Exception as e:
        logger.error(f"Error checking if media file exists: {str(e)}")
        return None