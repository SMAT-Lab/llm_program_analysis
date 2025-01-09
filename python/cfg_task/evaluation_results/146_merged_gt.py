import logging
import typing
import urllib.parse
import autogpt_libs.auth.depends
import autogpt_libs.auth.middleware
import fastapi
import fastapi.responses
import backend.data.graph
import backend.server.v2.store.db
import backend.server.v2.store.image_gen
import backend.server.v2.store.media
import backend.server.v2.store.model
logger = logging.getLogger(__name__)
router = fastapi.APIRouter()
@router.get('/profile', tags=['store', 'private'], response_model=backend.server.v2.store.model.ProfileDetails)
async def get_profile(user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    """
    Get the profile details for the authenticated user.
    """
    try:
        profile = await backend.server.v2.store.db.get_user_profile(user_id)
        return profile
    except Exception:
        logger.exception('Exception occurred whilst getting user profile')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the user profile'})
'\n    Get the profile details for the authenticated user.\n    '
try:
    profile = await backend.server.v2.store.db.get_user_profile(user_id)
    return profile
except Exception:
    logger.exception('Exception occurred whilst getting user profile')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the user profile'})
profile = await backend.server.v2.store.db.get_user_profile(user_id)
return profile
logger.exception('Exception occurred whilst getting user profile')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the user profile'})
@router.post('/profile', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=backend.server.v2.store.model.CreatorDetails)
async def update_or_create_profile(profile: backend.server.v2.store.model.Profile, user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    """
    Update the store profile for the authenticated user.

    Args:
        profile (Profile): The updated profile details
        user_id (str): ID of the authenticated user

    Returns:
        CreatorDetails: The updated profile

    Raises:
        HTTPException: If there is an error updating the profile
    """
    try:
        updated_profile = await backend.server.v2.store.db.update_or_create_profile(user_id=user_id, profile=profile)
        return updated_profile
    except Exception:
        logger.exception('Exception occurred whilst updating profile')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while updating the user profile'})
'\n    Update the store profile for the authenticated user.\n\n    Args:\n        profile (Profile): The updated profile details\n        user_id (str): ID of the authenticated user\n\n    Returns:\n        CreatorDetails: The updated profile\n\n    Raises:\n        HTTPException: If there is an error updating the profile\n    '
try:
    updated_profile = await backend.server.v2.store.db.update_or_create_profile(user_id=user_id, profile=profile)
    return updated_profile
except Exception:
    logger.exception('Exception occurred whilst updating profile')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while updating the user profile'})
updated_profile = await backend.server.v2.store.db.update_or_create_profile(user_id=user_id, profile=profile)
return updated_profile
logger.exception('Exception occurred whilst updating profile')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while updating the user profile'})
@router.get('/agents', tags=['store', 'public'], response_model=backend.server.v2.store.model.StoreAgentsResponse)
async def get_agents(featured: bool=False, creator: str | None=None, sorted_by: str | None=None, search_query: str | None=None, category: str | None=None, page: int=1, page_size: int=20):
    """
    Get a paginated list of agents from the store with optional filtering and sorting.

    Args:
        featured (bool, optional): Filter to only show featured agents. Defaults to False.
        creator (str | None, optional): Filter agents by creator username. Defaults to None.
        sorted_by (str | None, optional): Sort agents by "runs" or "rating". Defaults to None.
        search_query (str | None, optional): Search agents by name, subheading and description. Defaults to None.
        category (str | None, optional): Filter agents by category. Defaults to None.
        page (int, optional): Page number for pagination. Defaults to 1.
        page_size (int, optional): Number of agents per page. Defaults to 20.

    Returns:
        StoreAgentsResponse: Paginated list of agents matching the filters

    Raises:
        HTTPException: If page or page_size are less than 1

    Used for:
    - Home Page Featured Agents
    - Home Page Top Agents
    - Search Results
    - Agent Details - Other Agents By Creator
    - Agent Details - Similar Agents
    - Creator Details - Agents By Creator
    """
    if page < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
    if page_size < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
    try:
        agents = await backend.server.v2.store.db.get_store_agents(featured=featured, creator=creator, sorted_by=sorted_by, search_query=search_query, category=category, page=page, page_size=page_size)
        return agents
    except Exception:
        logger.exception('Exception occured whilst getting store agents')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agents'})
'\n    Get a paginated list of agents from the store with optional filtering and sorting.\n\n    Args:\n        featured (bool, optional): Filter to only show featured agents. Defaults to False.\n        creator (str | None, optional): Filter agents by creator username. Defaults to None.\n        sorted_by (str | None, optional): Sort agents by "runs" or "rating". Defaults to None.\n        search_query (str | None, optional): Search agents by name, subheading and description. Defaults to None.\n        category (str | None, optional): Filter agents by category. Defaults to None.\n        page (int, optional): Page number for pagination. Defaults to 1.\n        page_size (int, optional): Number of agents per page. Defaults to 20.\n\n    Returns:\n        StoreAgentsResponse: Paginated list of agents matching the filters\n\n    Raises:\n        HTTPException: If page or page_size are less than 1\n\n    Used for:\n    - Home Page Featured Agents\n    - Home Page Top Agents\n    - Search Results\n    - Agent Details - Other Agents By Creator\n    - Agent Details - Similar Agents\n    - Creator Details - Agents By Creator\n    '
page Lt 1
logger.exception('Exception occured whilst getting store agents')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agents'})
@router.get('/agents/{username}/{agent_name}', tags=['store', 'public'], response_model=backend.server.v2.store.model.StoreAgentDetails)
async def get_agent(username: str, agent_name: str):
    """
    This is only used on the AgentDetails Page

    It returns the store listing agents details.
    """
    try:
        username = urllib.parse.unquote(username).lower()
        agent_name = urllib.parse.unquote(agent_name).lower()
        agent = await backend.server.v2.store.db.get_store_agent_details(username=username, agent_name=agent_name)
        return agent
    except Exception:
        logger.exception('Exception occurred whilst getting store agent details')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agent details'})
'\n    This is only used on the AgentDetails Page\n\n    It returns the store listing agents details.\n    '
try:
    username = urllib.parse.unquote(username).lower()
    agent_name = urllib.parse.unquote(agent_name).lower()
    agent = await backend.server.v2.store.db.get_store_agent_details(username=username, agent_name=agent_name)
    return agent
except Exception:
    logger.exception('Exception occurred whilst getting store agent details')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agent details'})
username = urllib.parse.unquote(username).lower()
agent_name = urllib.parse.unquote(agent_name).lower()
agent = await backend.server.v2.store.db.get_store_agent_details(username=username, agent_name=agent_name)
return agent
logger.exception('Exception occurred whilst getting store agent details')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agent details'})
@router.post('/agents/{username}/{agent_name}/review', tags=['store'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=backend.server.v2.store.model.StoreReview)
async def create_review(username: str, agent_name: str, review: backend.server.v2.store.model.StoreReviewCreate, user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    """
    Create a review for a store agent.

    Args:
        username: Creator's username
        agent_name: Name/slug of the agent
        review: Review details including score and optional comments
        user_id: ID of authenticated user creating the review

    Returns:
        The created review
    """
    try:
        username = urllib.parse.unquote(username).lower()
        agent_name = urllib.parse.unquote(agent_name)
        created_review = await backend.server.v2.store.db.create_store_review(user_id=user_id, store_listing_version_id=review.store_listing_version_id, score=review.score, comments=review.comments)
        return created_review
    except Exception:
        logger.exception('Exception occurred whilst creating store review')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store review'})
"\n    Create a review for a store agent.\n\n    Args:\n        username: Creator's username\n        agent_name: Name/slug of the agent\n        review: Review details including score and optional comments\n        user_id: ID of authenticated user creating the review\n\n    Returns:\n        The created review\n    "
try:
    username = urllib.parse.unquote(username).lower()
    agent_name = urllib.parse.unquote(agent_name)
    created_review = await backend.server.v2.store.db.create_store_review(user_id=user_id, store_listing_version_id=review.store_listing_version_id, score=review.score, comments=review.comments)
    return created_review
except Exception:
    logger.exception('Exception occurred whilst creating store review')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store review'})
username = urllib.parse.unquote(username).lower()
agent_name = urllib.parse.unquote(agent_name)
created_review = await backend.server.v2.store.db.create_store_review(user_id=user_id, store_listing_version_id=review.store_listing_version_id, score=review.score, comments=review.comments)
return created_review
logger.exception('Exception occurred whilst creating store review')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store review'})
@router.get('/creators', tags=['store', 'public'], response_model=backend.server.v2.store.model.CreatorsResponse)
async def get_creators(featured: bool=False, search_query: str | None=None, sorted_by: str | None=None, page: int=1, page_size: int=20):
    """
    This is needed for:
    - Home Page Featured Creators
    - Search Results Page

    ---

    To support this functionality we need:
    - featured: bool - to limit the list to just featured agents
    - search_query: str - vector search based on the creators profile description.
    - sorted_by: [agent_rating, agent_runs] -
    """
    if page < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
    if page_size < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
    try:
        creators = await backend.server.v2.store.db.get_store_creators(featured=featured, search_query=search_query, sorted_by=sorted_by, page=page, page_size=page_size)
        return creators
    except Exception:
        logger.exception('Exception occurred whilst getting store creators')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store creators'})
'\n    This is needed for:\n    - Home Page Featured Creators\n    - Search Results Page\n\n    ---\n\n    To support this functionality we need:\n    - featured: bool - to limit the list to just featured agents\n    - search_query: str - vector search based on the creators profile description.\n    - sorted_by: [agent_rating, agent_runs] -\n    '
page Lt 1
logger.exception('Exception occurred whilst getting store creators')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store creators'})
@router.get('/creator/{username}', tags=['store', 'public'], response_model=backend.server.v2.store.model.CreatorDetails)
async def get_creator(username: str):
    """
    Get the details of a creator
    - Creator Details Page
    """
    try:
        username = urllib.parse.unquote(username).lower()
        creator = await backend.server.v2.store.db.get_store_creator_details(username=username.lower())
        return creator
    except Exception:
        logger.exception('Exception occurred whilst getting creator details')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the creator details'})
'\n    Get the details of a creator\n    - Creator Details Page\n    '
try:
    username = urllib.parse.unquote(username).lower()
    creator = await backend.server.v2.store.db.get_store_creator_details(username=username.lower())
    return creator
except Exception:
    logger.exception('Exception occurred whilst getting creator details')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the creator details'})
username = urllib.parse.unquote(username).lower()
creator = await backend.server.v2.store.db.get_store_creator_details(username=username.lower())
return creator
logger.exception('Exception occurred whilst getting creator details')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the creator details'})
@router.get('/myagents', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=backend.server.v2.store.model.MyAgentsResponse)
async def get_my_agents(user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    try:
        agents = await backend.server.v2.store.db.get_my_agents(user_id)
        return agents
    except Exception:
        logger.exception('Exception occurred whilst getting my agents')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the my agents'})
try:
    agents = await backend.server.v2.store.db.get_my_agents(user_id)
    return agents
except Exception:
    logger.exception('Exception occurred whilst getting my agents')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the my agents'})
agents = await backend.server.v2.store.db.get_my_agents(user_id)
return agents
logger.exception('Exception occurred whilst getting my agents')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the my agents'})
@router.delete('/submissions/{submission_id}', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=bool)
async def delete_submission(user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)], submission_id: str):
    """
    Delete a store listing submission.

    Args:
        user_id (str): ID of the authenticated user
        submission_id (str): ID of the submission to be deleted

    Returns:
        bool: True if the submission was successfully deleted, False otherwise
    """
    try:
        result = await backend.server.v2.store.db.delete_store_submission(user_id=user_id, submission_id=submission_id)
        return result
    except Exception:
        logger.exception('Exception occurred whilst deleting store submission')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while deleting the store submission'})
'\n    Delete a store listing submission.\n\n    Args:\n        user_id (str): ID of the authenticated user\n        submission_id (str): ID of the submission to be deleted\n\n    Returns:\n        bool: True if the submission was successfully deleted, False otherwise\n    '
try:
    result = await backend.server.v2.store.db.delete_store_submission(user_id=user_id, submission_id=submission_id)
    return result
except Exception:
    logger.exception('Exception occurred whilst deleting store submission')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while deleting the store submission'})
result = await backend.server.v2.store.db.delete_store_submission(user_id=user_id, submission_id=submission_id)
return result
logger.exception('Exception occurred whilst deleting store submission')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while deleting the store submission'})
@router.get('/submissions', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=backend.server.v2.store.model.StoreSubmissionsResponse)
async def get_submissions(user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)], page: int=1, page_size: int=20):
    """
    Get a paginated list of store submissions for the authenticated user.

    Args:
        user_id (str): ID of the authenticated user
        page (int, optional): Page number for pagination. Defaults to 1.
        page_size (int, optional): Number of submissions per page. Defaults to 20.

    Returns:
        StoreListingsResponse: Paginated list of store submissions

    Raises:
        HTTPException: If page or page_size are less than 1
    """
    if page < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
    if page_size < 1:
        raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
    try:
        listings = await backend.server.v2.store.db.get_store_submissions(user_id=user_id, page=page, page_size=page_size)
        return listings
    except Exception:
        logger.exception('Exception occurred whilst getting store submissions')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store submissions'})
'\n    Get a paginated list of store submissions for the authenticated user.\n\n    Args:\n        user_id (str): ID of the authenticated user\n        page (int, optional): Page number for pagination. Defaults to 1.\n        page_size (int, optional): Number of submissions per page. Defaults to 20.\n\n    Returns:\n        StoreListingsResponse: Paginated list of store submissions\n\n    Raises:\n        HTTPException: If page or page_size are less than 1\n    '
page Lt 1
logger.exception('Exception occurred whilst getting store submissions')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store submissions'})
@router.post('/submissions', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)], response_model=backend.server.v2.store.model.StoreSubmission)
async def create_submission(submission_request: backend.server.v2.store.model.StoreSubmissionRequest, user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    """
    Create a new store listing submission.

    Args:
        submission_request (StoreSubmissionRequest): The submission details
        user_id (str): ID of the authenticated user submitting the listing

    Returns:
        StoreSubmission: The created store submission

    Raises:
        HTTPException: If there is an error creating the submission
    """
    try:
        submission = await backend.server.v2.store.db.create_store_submission(user_id=user_id, agent_id=submission_request.agent_id, agent_version=submission_request.agent_version, slug=submission_request.slug, name=submission_request.name, video_url=submission_request.video_url, image_urls=submission_request.image_urls, description=submission_request.description, sub_heading=submission_request.sub_heading, categories=submission_request.categories)
        return submission
    except Exception:
        logger.exception('Exception occurred whilst creating store submission')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store submission'})
'\n    Create a new store listing submission.\n\n    Args:\n        submission_request (StoreSubmissionRequest): The submission details\n        user_id (str): ID of the authenticated user submitting the listing\n\n    Returns:\n        StoreSubmission: The created store submission\n\n    Raises:\n        HTTPException: If there is an error creating the submission\n    '
try:
    submission = await backend.server.v2.store.db.create_store_submission(user_id=user_id, agent_id=submission_request.agent_id, agent_version=submission_request.agent_version, slug=submission_request.slug, name=submission_request.name, video_url=submission_request.video_url, image_urls=submission_request.image_urls, description=submission_request.description, sub_heading=submission_request.sub_heading, categories=submission_request.categories)
    return submission
except Exception:
    logger.exception('Exception occurred whilst creating store submission')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store submission'})
submission = await backend.server.v2.store.db.create_store_submission(user_id=user_id, agent_id=submission_request.agent_id, agent_version=submission_request.agent_version, slug=submission_request.slug, name=submission_request.name, video_url=submission_request.video_url, image_urls=submission_request.image_urls, description=submission_request.description, sub_heading=submission_request.sub_heading, categories=submission_request.categories)
return submission
logger.exception('Exception occurred whilst creating store submission')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while creating the store submission'})
@router.post('/submissions/media', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)])
async def upload_submission_media(file: fastapi.UploadFile, user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]):
    """
    Upload media (images/videos) for a store listing submission.

    Args:
        file (UploadFile): The media file to upload
        user_id (str): ID of the authenticated user uploading the media

    Returns:
        str: URL of the uploaded media file

    Raises:
        HTTPException: If there is an error uploading the media
    """
    try:
        media_url = await backend.server.v2.store.media.upload_media(user_id=user_id, file=file)
        return media_url
    except Exception:
        logger.exception('Exception occurred whilst uploading submission media')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while uploading the media file'})
'\n    Upload media (images/videos) for a store listing submission.\n\n    Args:\n        file (UploadFile): The media file to upload\n        user_id (str): ID of the authenticated user uploading the media\n\n    Returns:\n        str: URL of the uploaded media file\n\n    Raises:\n        HTTPException: If there is an error uploading the media\n    '
try:
    media_url = await backend.server.v2.store.media.upload_media(user_id=user_id, file=file)
    return media_url
except Exception:
    logger.exception('Exception occurred whilst uploading submission media')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while uploading the media file'})
media_url = await backend.server.v2.store.media.upload_media(user_id=user_id, file=file)
return media_url
logger.exception('Exception occurred whilst uploading submission media')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while uploading the media file'})
@router.post('/submissions/generate_image', tags=['store', 'private'], dependencies=[fastapi.Depends(autogpt_libs.auth.middleware.auth_middleware)])
async def generate_image(agent_id: str, user_id: typing.Annotated[str, fastapi.Depends(autogpt_libs.auth.depends.get_user_id)]) -> fastapi.responses.Response:
    """
    Generate an image for a store listing submission.

    Args:
        agent_id (str): ID of the agent to generate an image for
        user_id (str): ID of the authenticated user

    Returns:
        JSONResponse: JSON containing the URL of the generated image
    """
    try:
        agent = await backend.data.graph.get_graph(agent_id, user_id=user_id)
        if not agent:
            raise fastapi.HTTPException(status_code=404, detail=f'Agent with ID {agent_id} not found')
        filename = f'agent_{agent_id}.jpeg'
        existing_url = await backend.server.v2.store.media.check_media_exists(user_id, filename)
        if existing_url:
            logger.info(f'Using existing image for agent {agent_id}')
            return fastapi.responses.JSONResponse(content={'image_url': existing_url})
        image = await backend.server.v2.store.image_gen.generate_agent_image(agent=agent)
        image_file = fastapi.UploadFile(file=image, filename=filename)
        image_url = await backend.server.v2.store.media.upload_media(user_id=user_id, file=image_file, use_file_name=True)
        return fastapi.responses.JSONResponse(content={'image_url': image_url})
    except Exception:
        logger.exception('Exception occurred whilst generating submission image')
        return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while generating the image'})
'\n    Generate an image for a store listing submission.\n\n    Args:\n        agent_id (str): ID of the agent to generate an image for\n        user_id (str): ID of the authenticated user\n\n    Returns:\n        JSONResponse: JSON containing the URL of the generated image\n    '
try:
    agent = await backend.data.graph.get_graph(agent_id, user_id=user_id)
    if not agent:
        raise fastapi.HTTPException(status_code=404, detail=f'Agent with ID {agent_id} not found')
    filename = f'agent_{agent_id}.jpeg'
    existing_url = await backend.server.v2.store.media.check_media_exists(user_id, filename)
    if existing_url:
        logger.info(f'Using existing image for agent {agent_id}')
        return fastapi.responses.JSONResponse(content={'image_url': existing_url})
    image = await backend.server.v2.store.image_gen.generate_agent_image(agent=agent)
    image_file = fastapi.UploadFile(file=image, filename=filename)
    image_url = await backend.server.v2.store.media.upload_media(user_id=user_id, file=image_file, use_file_name=True)
    return fastapi.responses.JSONResponse(content={'image_url': image_url})
except Exception:
    logger.exception('Exception occurred whilst generating submission image')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while generating the image'})
agent = await backend.data.graph.get_graph(agent_id, user_id=user_id)
not agent
logger.exception('Exception occurred whilst generating submission image')
return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while generating the image'})
raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
raise fastapi.HTTPException(status_code=422, detail='Page must be greater than 0')
raise fastapi.HTTPException(status_code=404, detail=f'Agent with ID {agent_id} not found')
page_size Lt 1
page_size Lt 1
page_size Lt 1
filename = f'agent_{agent_id}.jpeg'
existing_url = await backend.server.v2.store.media.check_media_exists(user_id, filename)
existing_url
raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
raise fastapi.HTTPException(status_code=422, detail='Page size must be greater than 0')
logger.info(f'Using existing image for agent {agent_id}')
return fastapi.responses.JSONResponse(content={'image_url': existing_url})
try:
    agents = await backend.server.v2.store.db.get_store_agents(featured=featured, creator=creator, sorted_by=sorted_by, search_query=search_query, category=category, page=page, page_size=page_size)
    return agents
except Exception:
    logger.exception('Exception occured whilst getting store agents')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store agents'})
agents = await backend.server.v2.store.db.get_store_agents(featured=featured, creator=creator, sorted_by=sorted_by, search_query=search_query, category=category, page=page, page_size=page_size)
return agents
try:
    creators = await backend.server.v2.store.db.get_store_creators(featured=featured, search_query=search_query, sorted_by=sorted_by, page=page, page_size=page_size)
    return creators
except Exception:
    logger.exception('Exception occurred whilst getting store creators')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store creators'})
creators = await backend.server.v2.store.db.get_store_creators(featured=featured, search_query=search_query, sorted_by=sorted_by, page=page, page_size=page_size)
return creators
try:
    listings = await backend.server.v2.store.db.get_store_submissions(user_id=user_id, page=page, page_size=page_size)
    return listings
except Exception:
    logger.exception('Exception occurred whilst getting store submissions')
    return fastapi.responses.JSONResponse(status_code=500, content={'detail': 'An error occurred while retrieving the store submissions'})
listings = await backend.server.v2.store.db.get_store_submissions(user_id=user_id, page=page, page_size=page_size)
return listings