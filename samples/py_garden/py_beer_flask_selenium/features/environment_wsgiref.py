from multiprocessing import Process
from wsgiref.validate import validator
from wsgiref.simple_server import make_server
import selenium.webdriver

import beer_app

def before_all(context):
    context.app = beer_app.create_app()
    context.app.config['TESTING'] = True
    # DEBUG == False if testing flask.app.run with selenium 
    # otherwise it make f*** mess !!!
    context.app.config['DEBUG'] = False
    context.baseurl = "http://127.0.0.1:8000/"
    context.browser = selenium.webdriver.Firefox()

def before_scenario(context, scenario):
    context.beer_json = context.app.config['BEER_JSON']
    if 'beerdesc' in scenario.tags:
        context.app.config['BEER_JSON'] = 'tests_json/test_beer_shortage.json'
    if 'encode' in scenario.tags:
        context.app.config['BEER_JSON'] = 'tests_json/test_beer_encode.json'
    # run app in subprocess
    # context.wsgi = make_server("", 8000, beer.app)
    context.wsgi = make_server("", 8000, validator(context.app))
    context.server = Process(target=context.wsgi.serve_forever)
    context.server.start()

def after_scenario(context, scenario):
    context.app.config['BEER_JSON'] = context.beer_json
    context.wsgi.shutdown
    context.server.terminate()
    context.server.join()

def after_all(context):
    context.browser.quit()
