# -- coding: cp1252 --
from Tkinter import *
import serial
import time
import sys

#CONFIGURACIÓN DE LA INTERFAZ
ventana = Tk()
ventana.title('PROYECTO FINAL')
ventana.resizable(0,0)
ventana.geometry("300x200")



ventana.configure(background = 'blue' )


#FRAMES
box=Frame()
box.pack()
box.config(width='500',height="200")

#GRABACION DE LA RUTINA
grabar_rutina = Label(box,text='Inicio de la grabación',fg='black',bg='green')
grabar_rutina.place(x=80,y=10)

#REALIZAR LA GRABACIÓN
angulo = Label(box, text='Realizar grabacion',fg='black',bg='yellow').place(x=100,y=100)

def grabar():
    global var
    var = ser.read()
def ejecutar():
    var2 = ser.write(var)
    print var
    


push = Button(box,text='Grabar',command = grabar)#,command = mapear)
push.place(x=130,y=50)

push2 = Button(box,text = 'Ejecutar',command = ejecutar)
push2.place(x=130,y=135)
global ser
ser= serial.Serial(port='COM18',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
while 1:
    ser.flushInput()
    ser.flushOutput()
    time.sleep(.3)
    recibido1=ser.read()
    #ser.write(mapeo)
    numero2 = ord(recibido1)
    numero=float(numero2)
    numero=(numero*5.0)/255.0
    #print(numero2)
    ventana.update()






