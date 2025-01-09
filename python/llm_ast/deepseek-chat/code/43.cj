從 autogpt_libs.auth.depends 引入 requires_user
從 autogpt_libs.auth.models 引入 User
從 fastapi 引入 Depends
從 backend.util.settings 引入 Settings

設定 settings = Settings()

定義 get_user_id(用戶: User = Depends(requires_user)) -> 字串:
    返回 用戶.user_id