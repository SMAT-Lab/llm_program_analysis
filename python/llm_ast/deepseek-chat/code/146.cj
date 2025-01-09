// 定义全局程序
program Global {
    // 定义函数 get_profile
    function get_profile(user_id: str) async -> ProfileDetails {
        try {
            profile = await backend.server.v2.store.db.get_user_profile(user_id)
            return profile
        } catch Exception {
            logger.exception("Exception occurred whilst getting user profile")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the user profile"}
            )
        }
    }

    // 定义函数 update_or_create_profile
    function update_or_create_profile(profile: Profile, user_id: str) async -> CreatorDetails {
        try {
            updated_profile = await backend.server.v2.store.db.update_or_create_profile(user_id, profile)
            return updated_profile
        } catch Exception {
            logger.exception("Exception occurred whilst updating profile")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while updating the user profile"}
            )
        }
    }

    // 定义函数 get_agents
    function get_agents(
        featured: bool = False,
        creator: str | None = None,
        sorted_by: str | None = None,
        search_query: str | None = None,
        category: str | None = None,
        page: int = 1,
        page_size: int = 20
    ) async -> StoreAgentsResponse {
        if page < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page must be greater than 0")
        }
        if page_size < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page size must be greater than 0")
        }
        try {
            agents = await backend.server.v2.store.db.get_store_agents(
                featured=featured,
                creator=creator,
                sorted_by=sorted_by,
                search_query=search_query,
                category=category,
                page=page,
                page_size=page_size
            )
            return agents
        } catch Exception {
            logger.exception("Exception occurred whilst getting store agents")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the store agents"}
            )
        }
    }

    // 定义函数 get_agent
    function get_agent(username: str, agent_name: str) async -> StoreAgentDetails {
        try {
            username = urllib.parse.unquote(username).lower()
            agent_name = urllib.parse.unquote(agent_name).lower()
            agent = await backend.server.v2.store.db.get_store_agent_details(username, agent_name)
            return agent
        } catch Exception {
            logger.exception("Exception occurred whilst getting store agent details")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the store agent details"}
            )
        }
    }

    // 定义函数 create_review
    function create_review(username: str, agent_name: str, review: StoreReviewCreate, user_id: str) async -> StoreReview {
        try {
            username = urllib.parse.unquote(username).lower()
            agent_name = urllib.parse.unquote(agent_name)
            created_review = await backend.server.v2.store.db.create_store_review(
                user_id=user_id,
                store_listing_version_id=review.store_listing_version_id,
                score=review.score,
                comments=review.comments
            )
            return created_review
        } catch Exception {
            logger.exception("Exception occurred whilst creating store review")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while creating the store review"}
            )
        }
    }

    // 定义函数 get_creators
    function get_creators(
        featured: bool = False,
        search_query: str | None = None,
        sorted_by: str | None = None,
        page: int = 1,
        page_size: int = 20
    ) async -> CreatorsResponse {
        if page < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page must be greater than 0")
        }
        if page_size < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page size must be greater than 0")
        }
        try {
            creators = await backend.server.v2.store.db.get_store_creators(
                featured=featured,
                search_query=search_query,
                sorted_by=sorted_by,
                page=page,
                page_size=page_size
            )
            return creators
        } catch Exception {
            logger.exception("Exception occurred whilst getting store creators")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the store creators"}
            )
        }
    }

    // 定义函数 get_creator
    function get_creator(username: str) async -> CreatorDetails {
        try {
            username = urllib.parse.unquote(username).lower()
            creator = await backend.server.v2.store.db.get_store_creator_details(username)
            return creator
        } catch Exception {
            logger.exception("Exception occurred whilst getting creator details")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the creator details"}
            )
        }
    }

    // 定义函数 get_my_agents
    function get_my_agents(user_id: str) async -> MyAgentsResponse {
        try {
            agents = await backend.server.v2.store.db.get_my_agents(user_id)
            return agents
        } catch Exception {
            logger.exception("Exception occurred whilst getting my agents")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the my agents"}
            )
        }
    }

    // 定义函数 delete_submission
    function delete_submission(user_id: str, submission_id: str) async -> bool {
        try {
            result = await backend.server.v2.store.db.delete_store_submission(user_id, submission_id)
            return result
        } catch Exception {
            logger.exception("Exception occurred whilst deleting store submission")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while deleting the store submission"}
            )
        }
    }

    // 定义函数 get_submissions
    function get_submissions(user_id: str, page: int = 1, page_size: int = 20) async -> StoreSubmissionsResponse {
        if page < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page must be greater than 0")
        }
        if page_size < 1 {
            raise fastapi.HTTPException(status_code=422, detail="Page size must be greater than 0")
        }
        try {
            listings = await backend.server.v2.store.db.get_store_submissions(
                user_id=user_id,
                page=page,
                page_size=page_size
            )
            return listings
        } catch Exception {
            logger.exception("Exception occurred whilst getting store submissions")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while retrieving the store submissions"}
            )
        }
    }

    // 定义函数 create_submission
    function create_submission(submission_request: StoreSubmissionRequest, user_id: str) async -> StoreSubmission {
        try {
            submission = await backend.server.v2.store.db.create_store_submission(
                user_id=user_id,
                agent_id=submission_request.agent_id,
                agent_version=submission_request.agent_version,
                slug=submission_request.slug,
                name=submission_request.name,
                video_url=submission_request.video_url,
                image_urls=submission_request.image_urls,
                description=submission_request.description,
                sub_heading=submission_request.sub_heading,
                categories=submission_request.categories
            )
            return submission
        } catch Exception {
            logger.exception("Exception occurred whilst creating store submission")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while creating the store submission"}
            )
        }
    }

    // 定义函数 upload_submission_media
    function upload_submission_media(file: fastapi.UploadFile, user_id: str) async -> str {
        try {
            media_url = await backend.server.v2.store.media.upload_media(user_id, file)
            return media_url
        } catch Exception {
            logger.exception("Exception occurred whilst uploading submission media")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while uploading the media file"}
            )
        }
    }

    // 定义函数 generate_image
    function generate_image(agent_id: str, user_id: str) async -> fastapi.responses.Response {
        try {
            agent = await backend.data.graph.get_graph(agent_id, user_id=user_id)
            if not agent {
                raise fastapi.HTTPException(status_code=404, detail=f"Agent with ID {agent_id} not found")
            }
            filename = f"agent_{agent_id}.jpeg"
            existing_url = await backend.server.v2.store.media.check_media_exists(user_id, filename)
            if existing_url {
                logger.info(f"Using existing image for agent {agent_id}")
                return fastapi.responses.JSONResponse(content={"image_url": existing_url})
            }
            image = await backend.server.v2.store.image_gen.generate_agent_image(agent=agent)
            image_file = fastapi.UploadFile(file=image, filename=filename)
            image_url = await backend.server.v2.store.media.upload_media(user_id, image_file, use_file_name=True)
            return fastapi.responses.JSONResponse(content={"image_url": image_url})
        } catch Exception {
            logger.exception("Exception occurred whilst generating submission image")
            return fastapi.responses.JSONResponse(
                status_code=500,
                content={"detail": "An error occurred while generating the submission image"}
            )
        }
    }
}