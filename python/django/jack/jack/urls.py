"""jack URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/1.8/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  url(r'^$', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  url(r'^$', Home.as_view(), name='home')
Including another URLconf
    1. Add a URL to urlpatterns:  url(r'^blog/', include('blog.urls'))
"""
import json
import logging

from django.conf.urls import include, url
from django.contrib import admin
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view

logging.basicConfig()


@csrf_exempt
def dump(request):
    print '------------'
    logging.info(request.body)
    print request.body
    print request.__dict__
    print type(request.path)
    print type(request.method)

    data = json.loads(request.body)
    for k, v in data.items():
        print k, type(k)
        print v, type(v)
    if 'a' in data:
        print 'fuckfuck'

    print json.dumps(data)
    print '------------'
    return HttpResponse('fuck')


@api_view(['POST'])
def dump2(request):
    print request.data
    data = request.data
    print type(data)
    for k, v in data.items():
        print k, type(k)
        print v, type(v)
    if 'a' in data:
        print 'fuckfuck'
    return HttpResponse('fuck')


urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^json/?$', dump),
    url(r'^json2/?$', dump2)
]
