from flask_socketio import emit, join_room, leave_room
# from celery.task.control import revoke

from launchpad import SOCKETIO

from gevent import monkey, kill

monkey.patch_all()


@SOCKETIO.on('leave')
def leave(data):
    user = data['user']
    leave_room(user)

@SOCKETIO.on('join')
def join(data):
    user = data['user']
    join_room(user)


@SOCKETIO.on('submit_input')
def submit_input(data):
    emit('response', data, room=data['sender'])
    return data['input']


@SOCKETIO.on('terminate')
def terminate_task(data):
    task_id = data['id']
    # revoke(task_id, terminate=True)
    kill(task_id)
    print(f'Revoking task {task_id}')
    return
