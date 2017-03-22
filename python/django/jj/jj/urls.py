"""jj URL Configuration

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
from django.conf.urls import include, url
from django.contrib import admin


from rest_framework.decorators import api_view
from rest_framework.response import Response

3

@api_view(['POST'])
def dump(request):
    print '------------'
    print request.data
    data = request.data
    for k,v in data.items():
        print k, type(k)
        print v, type(v)

    import json
    print json.dumps(data)
    print '------------'
    return Response('fuck')



urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^json/', dump)
]

