class AIVideoGeneratorBlock {
    class Input {
        prompt: str = SchemaField(
            description="Description of the video to generate.",
            placeholder="A dog running in a field."
        )
        model: FalModel = SchemaField(
            title="FAL Model",
            default=FalModel.MOCHI,
            description="The FAL model to use for video generation."
        )
        credentials: FalCredentialsInput = FalCredentialsField()
    }

    class Output {
        video_url: str = SchemaField(description="The URL of the generated video.")
        error: str = SchemaField(
            description="Error message if video generation failed."
        )
        logs: list[str] = SchemaField(
            description="Generation progress logs.",
            optional=True
        )
    }

    def __init__(self) {
        super().__init__(
            id="530cf046-2ce0-4854-ae2c-659db17c7a46",
            description="Generate videos using FAL AI models.",
            categories={BlockCategory.AI},
            input_schema=self.Input,
            output_schema=self.Output,
            test_input={
                "prompt": "A dog running in a field.",
                "model": FalModel.MOCHI,
                "credentials": TEST_CREDENTIALS_INPUT
            },
            test_credentials=TEST_CREDENTIALS,
            test_output=[("video_url", "https://fal.media/files/example/video.mp4")],
            test_mock={
                "generate_video": lambda *args, **kwargs: "https://fal.media/files/example/video.mp4"
            }
        )
    }
}