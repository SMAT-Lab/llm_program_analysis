import logging
import os
import uuid
import fastapi
from google.cloud import storage
import backend.server.v2.store.exceptions
from backend.util.settings import Settings
logger = logging.getLogger(__name__)
ALLOWED_IMAGE_TYPES = {'image/jpeg', 'image/png', 'image/gif', 'image/webp'}
ALLOWED_VIDEO_TYPES = {'video/mp4', 'video/webm'}
MAX_FILE_SIZE = 50 * 1024 * 1024
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
        image_path = f'users/{user_id}/images/{filename}'
        image_blob = bucket.blob(image_path)
        if image_blob.exists():
            return image_blob.public_url
        video_path = f'users/{user_id}/videos/{filename}'
        video_blob = bucket.blob(video_path)
        if video_blob.exists():
            return video_blob.public_url
        return None
    except Exception as e:
        logger.error(f'Error checking if media file exists: {str(e)}')
        return None
'\n    Check if a media file exists in storage for the given user.\n    Tries both images and videos directories.\n\n    Args:\n        user_id (str): ID of the user who uploaded the file\n        filename (str): Name of the file to check\n\n    Returns:\n        str | None: URL of the blob if it exists, None otherwise\n    '
try:
    settings = Settings()
    storage_client = storage.Client()
    bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
    image_path = f'users/{user_id}/images/{filename}'
    image_blob = bucket.blob(image_path)
    if image_blob.exists():
        return image_blob.public_url
    video_path = f'users/{user_id}/videos/{filename}'
    video_blob = bucket.blob(video_path)
    if video_blob.exists():
        return video_blob.public_url
    return None
except Exception as e:
    logger.error(f'Error checking if media file exists: {str(e)}')
    return None
settings = Settings()
storage_client = storage.Client()
bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
image_path = f'users/{user_id}/images/{filename}'
image_blob = bucket.blob(image_path)
image_blob.exists()
return image_blob.public_url
return video_blob.public_url
logger.error(f'Error checking if media file exists: {str(e)}')
return None
async def upload_media(user_id: str, file: fastapi.UploadFile, use_file_name: bool=False) -> str:
    try:
        content = await file.read(1024)
        await file.seek(0)
    except Exception as e:
        logger.error(f'Error reading file content: {str(e)}')
        raise backend.server.v2.store.exceptions.FileReadError('Failed to read file content') from e
    if file.content_type in ALLOWED_IMAGE_TYPES:
        if content.startswith(b'\xff\xd8\xff'):
            if file.content_type != 'image/jpeg':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        elif content.startswith(b'\x89PNG\r\n\x1a\n'):
            if file.content_type != 'image/png':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        elif content.startswith(b'GIF87a') or content.startswith(b'GIF89a'):
            if file.content_type != 'image/gif':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        elif content.startswith(b'RIFF') and content[8:12] == b'WEBP':
            if file.content_type != 'image/webp':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        else:
            raise backend.server.v2.store.exceptions.InvalidFileTypeError('Invalid image file signature')
    elif file.content_type in ALLOWED_VIDEO_TYPES:
        if content.startswith(b'\x00\x00\x00') and content[4:8] == b'ftyp':
            if file.content_type != 'video/mp4':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        elif content.startswith(b'\x1aE\xdf\xa3'):
            if file.content_type != 'video/webm':
                raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
        else:
            raise backend.server.v2.store.exceptions.InvalidFileTypeError('Invalid video file signature')
    settings = Settings()
    if not settings.config.media_gcs_bucket_name:
        logger.error('Missing GCS bucket name setting')
        raise backend.server.v2.store.exceptions.StorageConfigError('Missing storage bucket configuration')
    try:
        content_type = file.content_type
        if content_type is None:
            content_type = 'image/jpeg'
        if content_type not in ALLOWED_IMAGE_TYPES and content_type not in ALLOWED_VIDEO_TYPES:
            logger.warning(f'Invalid file type attempted: {content_type}')
            raise backend.server.v2.store.exceptions.InvalidFileTypeError(f'File type not supported. Must be jpeg, png, gif, webp, mp4 or webm. Content type: {content_type}')
        file_size = 0
        chunk_size = 8192
        try:
            while (chunk := (await file.read(chunk_size))):
                file_size += len(chunk)
                if file_size > MAX_FILE_SIZE:
                    logger.warning(f'File size too large: {file_size} bytes')
                    raise backend.server.v2.store.exceptions.FileSizeTooLargeError('File too large. Maximum size is 50MB')
        except backend.server.v2.store.exceptions.FileSizeTooLargeError:
            raise
        except Exception as e:
            logger.error(f'Error reading file chunks: {str(e)}')
            raise backend.server.v2.store.exceptions.FileReadError('Failed to read uploaded file') from e
        await file.seek(0)
        filename = file.filename or ''
        file_ext = os.path.splitext(filename)[1].lower()
        if use_file_name:
            unique_filename = filename
        else:
            unique_filename = f'{uuid.uuid4()}{file_ext}'
        media_type = 'images' if content_type in ALLOWED_IMAGE_TYPES else 'videos'
        storage_path = f'users/{user_id}/{media_type}/{unique_filename}'
        try:
            storage_client = storage.Client()
            bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
            blob = bucket.blob(storage_path)
            blob.content_type = content_type
            file_bytes = await file.read()
            blob.upload_from_string(file_bytes, content_type=content_type)
            public_url = blob.public_url
            logger.info(f'Successfully uploaded file to: {storage_path}')
            return public_url
        except Exception as e:
            logger.error(f'GCS storage error: {str(e)}')
            raise backend.server.v2.store.exceptions.StorageUploadError('Failed to upload file to storage') from e
    except backend.server.v2.store.exceptions.MediaUploadError:
        raise
    except Exception as e:
        logger.exception('Unexpected error in upload_media')
        raise backend.server.v2.store.exceptions.MediaUploadError('Unexpected error during media upload') from e
try:
    content = await file.read(1024)
    await file.seek(0)
except Exception as e:
    logger.error(f'Error reading file content: {str(e)}')
    raise backend.server.v2.store.exceptions.FileReadError('Failed to read file content') from e
content = await file.read(1024)
await file.seek(0)
logger.error(f'Error reading file content: {str(e)}')
raise backend.server.v2.store.exceptions.FileReadError('Failed to read file content') from e
file.content_type In ALLOWED_IMAGE_TYPES
content.startswith(b'\xff\xd8\xff')
file.content_type In ALLOWED_VIDEO_TYPES
settings = Settings()
not settings.config.media_gcs_bucket_name
file.content_type NotEq 'image/jpeg'
content.startswith(b'\x89PNG\r\n\x1a\n')
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
file.content_type NotEq 'image/png'
content.startswith(b'GIF87a') or content.startswith(b'GIF89a')
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
file.content_type NotEq 'image/gif'
content.startswith(b'RIFF') and content[8:12] == b'WEBP'
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
file.content_type NotEq 'image/webp'
raise backend.server.v2.store.exceptions.InvalidFileTypeError('Invalid image file signature')
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
content.startswith(b'\x00\x00\x00') and content[4:8] == b'ftyp'
file.content_type NotEq 'video/mp4'
content.startswith(b'\x1aE\xdf\xa3')
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
file.content_type NotEq 'video/webm'
raise backend.server.v2.store.exceptions.InvalidFileTypeError('Invalid video file signature')
raise backend.server.v2.store.exceptions.InvalidFileTypeError('File signature does not match content type')
logger.error('Missing GCS bucket name setting')
raise backend.server.v2.store.exceptions.StorageConfigError('Missing storage bucket configuration')
try:
    content_type = file.content_type
    if content_type is None:
        content_type = 'image/jpeg'
    if content_type not in ALLOWED_IMAGE_TYPES and content_type not in ALLOWED_VIDEO_TYPES:
        logger.warning(f'Invalid file type attempted: {content_type}')
        raise backend.server.v2.store.exceptions.InvalidFileTypeError(f'File type not supported. Must be jpeg, png, gif, webp, mp4 or webm. Content type: {content_type}')
    file_size = 0
    chunk_size = 8192
    try:
        while (chunk := (await file.read(chunk_size))):
            file_size += len(chunk)
            if file_size > MAX_FILE_SIZE:
                logger.warning(f'File size too large: {file_size} bytes')
                raise backend.server.v2.store.exceptions.FileSizeTooLargeError('File too large. Maximum size is 50MB')
    except backend.server.v2.store.exceptions.FileSizeTooLargeError:
        raise
    except Exception as e:
        logger.error(f'Error reading file chunks: {str(e)}')
        raise backend.server.v2.store.exceptions.FileReadError('Failed to read uploaded file') from e
    await file.seek(0)
    filename = file.filename or ''
    file_ext = os.path.splitext(filename)[1].lower()
    if use_file_name:
        unique_filename = filename
    else:
        unique_filename = f'{uuid.uuid4()}{file_ext}'
    media_type = 'images' if content_type in ALLOWED_IMAGE_TYPES else 'videos'
    storage_path = f'users/{user_id}/{media_type}/{unique_filename}'
    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
        blob = bucket.blob(storage_path)
        blob.content_type = content_type
        file_bytes = await file.read()
        blob.upload_from_string(file_bytes, content_type=content_type)
        public_url = blob.public_url
        logger.info(f'Successfully uploaded file to: {storage_path}')
        return public_url
    except Exception as e:
        logger.error(f'GCS storage error: {str(e)}')
        raise backend.server.v2.store.exceptions.StorageUploadError('Failed to upload file to storage') from e
except backend.server.v2.store.exceptions.MediaUploadError:
    raise
except Exception as e:
    logger.exception('Unexpected error in upload_media')
    raise backend.server.v2.store.exceptions.MediaUploadError('Unexpected error during media upload') from e
content_type = file.content_type
content_type Is None
content_type = 'image/jpeg'
content_type not in ALLOWED_IMAGE_TYPES and content_type not in ALLOWED_VIDEO_TYPES
logger.warning(f'Invalid file type attempted: {content_type}')
raise backend.server.v2.store.exceptions.InvalidFileTypeError(f'File type not supported. Must be jpeg, png, gif, webp, mp4 or webm. Content type: {content_type}')
file_size = 0
chunk_size = 8192
try:
    while (chunk := (await file.read(chunk_size))):
        file_size += len(chunk)
        if file_size > MAX_FILE_SIZE:
            logger.warning(f'File size too large: {file_size} bytes')
            raise backend.server.v2.store.exceptions.FileSizeTooLargeError('File too large. Maximum size is 50MB')
except backend.server.v2.store.exceptions.FileSizeTooLargeError:
    raise
except Exception as e:
    logger.error(f'Error reading file chunks: {str(e)}')
    raise backend.server.v2.store.exceptions.FileReadError('Failed to read uploaded file') from e
(chunk := (await file.read(chunk_size)))
file_size += len(chunk)
file_size Gt MAX_FILE_SIZE
raise
logger.error(f'Error reading file chunks: {str(e)}')
raise backend.server.v2.store.exceptions.FileReadError('Failed to read uploaded file') from e
await file.seek(0)
filename = file.filename or ''
file_ext = os.path.splitext(filename)[1].lower()
use_file_name
logger.warning(f'File size too large: {file_size} bytes')
raise backend.server.v2.store.exceptions.FileSizeTooLargeError('File too large. Maximum size is 50MB')
unique_filename = filename
unique_filename = f'{uuid.uuid4()}{file_ext}'
media_type = 'images' if content_type in ALLOWED_IMAGE_TYPES else 'videos'
storage_path = f'users/{user_id}/{media_type}/{unique_filename}'
try:
    storage_client = storage.Client()
    bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
    blob = bucket.blob(storage_path)
    blob.content_type = content_type
    file_bytes = await file.read()
    blob.upload_from_string(file_bytes, content_type=content_type)
    public_url = blob.public_url
    logger.info(f'Successfully uploaded file to: {storage_path}')
    return public_url
except Exception as e:
    logger.error(f'GCS storage error: {str(e)}')
    raise backend.server.v2.store.exceptions.StorageUploadError('Failed to upload file to storage') from e
storage_client = storage.Client()
bucket = storage_client.bucket(settings.config.media_gcs_bucket_name)
blob = bucket.blob(storage_path)
blob.content_type = content_type
file_bytes = await file.read()
blob.upload_from_string(file_bytes)
public_url = blob.public_url
logger.info(f'Successfully uploaded file to: {storage_path}')
return public_url
logger.error(f'GCS storage error: {str(e)}')
raise backend.server.v2.store.exceptions.StorageUploadError('Failed to upload file to storage') from e
raise
logger.exception('Unexpected error in upload_media')
raise backend.server.v2.store.exceptions.MediaUploadError('Unexpected error during media upload') from e