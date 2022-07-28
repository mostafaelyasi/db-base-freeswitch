#!/usr/bin/python
from config import config
import freeswitch
import psycopg2
  

def get_user_status(called_number): 
    """ query data from the registrations table """ 
    conn = None 
    is_register = True
    try:
        #conn = psycopg2.connect(host="127.0.0.1",database="fscore", user="fsuser", port=5432 , password="PASS")
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        select_str = "SELECT reg_user FROM registrations where reg_user = '" + str(called_number)+ "'"
        cur.execute(select_str)
        if cur.rowcount < 1 :
            is_register=False
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        freeswitch.consoleLog('info', '***** Error: %s\n' % error)
    finally:
        if conn is not None:
            conn.close()
    return is_register
  

def handler(session, args):
    freeswitch.consoleLog('info', '*****Answering call from Python.\n')
    freeswitch.consoleLog('info', '*****Arguments: %s\n' % args)
    freeswitch.consoleLog('info', '*****Caller Number: %s\n' % session.getVariable("caller_id_name"))
    freeswitch.consoleLog('info', '*****Caller Destionation Number: %s\n' % session.getVariable("destination_number"))
  
    called_number=session.getVariable("destination_number")
    is_register=get_user_status(called_number)
    if not is_register:
        call_addr='user/1022'
        session.execute("bridge", call_addr)
