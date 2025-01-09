import contextlib
import logging.config
import os
import dotenv
import fastapi
import fastapi.middleware.cors
import fastapi.middleware.gzip
import prisma
import prometheus_fastapi_instrumentator
import sentry_sdk
import sentry_sdk.integrations.asyncio
import sentry_sdk.integrations.fastapi
import sentry_sdk.integrations.starlette
import market.config
import market.routes.admin
import market.routes.agents
import market.routes.analytics
import market.routes.search
import market.routes.submissions
dotenv.load_dotenv()
logging.config.dictConfig(market.config.LogConfig().model_dump())
os.environ.get('SENTRY_DSN')
@app.get('/')
def default():
    return fastapi.responses.HTMLResponse(content='<h1>Marketplace API</h1>', status_code=200)
return fastapi.responses.HTMLResponse(content='<h1>Marketplace API</h1>', status_code=200)
prometheus_fastapi_instrumentator.Instrumentator().instrument(app).expose(app)
sentry_sdk.init()
db_client = prisma.Prisma(auto_register=True)
@contextlib.asynccontextmanager
async def lifespan(app: fastapi.FastAPI):
    await db_client.connect()
    yield
    await db_client.disconnect()
await db_client.connect()
(yield)
await db_client.disconnect()
docs_url = '/docs'
app = fastapi.FastAPI(title='Marketplace API', description='AutoGPT Marketplace API is a service that allows users to share AI agents.', summary='Maketplace API', version='0.1', lifespan=lifespan, root_path='/api/v1/market', docs_url=docs_url)
app.add_middleware(fastapi.middleware.gzip.GZipMiddleware)
app.add_middleware()
app.include_router(market.routes.agents.router)
app.include_router(market.routes.search.router)
app.include_router(market.routes.submissions.router)
app.include_router(market.routes.admin.router)
app.include_router(market.routes.analytics.router)
@app.get('/health')
def health():
    return fastapi.responses.HTMLResponse(content='<h1>Marketplace API</h1>', status_code=200)
return fastapi.responses.HTMLResponse(content='<h1>Marketplace API</h1>', status_code=200)