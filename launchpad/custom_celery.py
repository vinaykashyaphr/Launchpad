from celery import Task

from flask import has_request_context, make_response, request

from launchpad import APP


# def task(**kwargs):
#     def decorator(func):
#         @CELERY.task(**kwargs)
#         @functools.wraps(func)
#         def wrapped(*args, **kwargs):
#             with APP.test_request_context():
#                 return func(*args, **kwargs)
#         return wrapped

#     return decorator

__all__ = ['RequestContextTask']


class RequestContextTask(Task):
    CONTEXT_ARG_NAME = '_flask_request_context'
    abstract = True

    def __call__(self, *args, **kwargs):
        def call():
            return super(RequestContextTask, self).__call__(*args, **kwargs)

        context = kwargs.pop(self.CONTEXT_ARG_NAME, None)
        if context is None or has_request_context():
            return call()

        with APP.test_request_context(**context):
            result = call()
            APP.process_response(make_response(result or ''))

        return result

    def apply_async(self, args=None, kwargs=None, **rest):
        self._include_request_context(kwargs)
        return super(RequestContextTask, self).apply_async(args, kwargs,
                                                           **rest)

    def apply(self, args=None, kwargs=None, **rest):
        self._include_request_context(kwargs)
        return super(RequestContextTask, self).apply(args, kwargs, **rest)

    def retry(self, args=None, kwargs=None, **rest):
        self._include_request_context(kwargs)
        return super(RequestContextTask, self).retry(args, kwargs, **rest)

    def _include_request_context(self, kwargs):
        if not has_request_context():
            return

        context = {
            'path': request.path,
            'base_url': request.url_root,
            'method': request.method,
            'headers': dict(request.headers),
        }

        if '?' in request.url:
            context['query_string'] = request.url[(request.url.find('?') + 1):]

        kwargs[self.CONTEXT_ARG_NAME] = context
