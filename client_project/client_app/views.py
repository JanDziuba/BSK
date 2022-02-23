from django.shortcuts import render, redirect
import pam
from os import listdir, stat
from pwd import getpwuid


def login(request):
    client_id = request.POST.get('username')
    client_password = request.POST.get('password')

    if pam.authenticate(client_id, client_password):
        request.session['client_id'] = client_id
        request.session['logged_in'] = 'true'
        return redirect('home_view')
    else:
        request.session['error'] = 'login failed'
        return redirect('login_view')


def logout(request):
    if request.POST.get('log_out') is not None:
        request.session['logged_in'] = 'false'
        return redirect('login_view')


def login_view(request):
    context = {'error': request.session.get('error', '')}
    request.session['error'] = ''
    return render(request, 'client_app/login.html', context)


def find_owner(file_path):
    return getpwuid(stat(file_path).st_uid).pw_name


def get_file_content(file_path):
    file = open(file_path)
    content = file.read()
    file.close()
    return content


def get_client_files(client_id, dir_path):
    files_content_str = ''

    for file_name in listdir(dir_path):
        file_path = dir_path + '/' + file_name
        if find_owner(file_path) == client_id:
            files_content_str += file_name + '\n\n'
            files_content_str += get_file_content(file_path)

    return files_content_str


def get_client_deposits_and_credits(client_id):
    files_content_str = '\ndeposits\n\n'
    files_content_str += get_client_files(client_id, '../deposits')
    files_content_str += '\ncredits\n\n'
    files_content_str += get_client_files(client_id, '../credits')
    return files_content_str


def home_view(request):
    if request.session.get('logged_in') != 'true':
        return redirect('login_view')

    client_id = request.session['client_id']
    deposits_and_credits = get_client_deposits_and_credits(client_id)

    context = {'client_id': client_id, 'deposits_and_credits': deposits_and_credits}
    return render(request, 'client_app/home.html', context)
