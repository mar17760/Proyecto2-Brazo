#Jose Pablo Marroquin L. - 17760
#Segudo Ciclo 2018
from tkinter import *
from tkinter import ttk
import tkinter

root = Tk()
root.title('Programación de Microcontroladores | Proyecto 2')
h = 320
w = 460
x=-7
y=0
root.geometry('%dx%d+%d+%d' % (w,h,x, y))
root.maxsize(width=800, height=600)
root.minsize(width=280, height=240)
color='bisque'#'AntiqueWhite2'
colorb='blanched almond'#'navajo white'#'lemon chiffon'
colort='blue4'
colorg='lime green'
colorp='cyan3'
root.configure(background=color)
titulo = Label(root, text = 'Brazo robot', fg =colort, bg=color, font=(None, 14, 'bold')).grid(row=1, column=1, columnspan=5)
root.grid_rowconfigure(0, weight=1, minsize=10)
root.grid_rowconfigure(1, weight=3, minsize=14)
root.grid_rowconfigure(4, weight=1, minsize=10)
root.grid_rowconfigure(7, weight=1, minsize=10)
root.grid_rowconfigure(9, weight=1, minsize=10)
root.grid_rowconfigure(11, weight=1, minsize=10)
root.grid_columnconfigure(0, weight=1, minsize=10)
root.grid_columnconfigure(2, weight=1, minsize=10)
root.grid_columnconfigure(3, weight=1, minsize=40)
root.grid_columnconfigure(4, weight=1, minsize=10)
root.grid_columnconfigure(5, weight=1, minsize=10)
root.grid_columnconfigure(6, weight=1, minsize=10)
modos = Label(root, text='Modos', fg=colort, bg=color, font=(None, 12, 'bold')).grid(row=2, column=1, columnspan=5, sticky=NW)
modo='Rutinas'
mode0 = Label(root, text='Modo actual:', fg=colort, bg=color).grid(row=3, column=1, sticky=NSEW)
mode = Label(root, text=modo, fg='DodgerBlue3', bg=color, font=(None, 11, 'bold italic')).grid(row=3, column=2, columnspan=2, sticky=NSEW)
cambio = Button(root, text='Cambiar modo', fg=colort, bg=colorb, activebackground='DodgerBlue1').grid(row=3, column=4, columnspan=2, sticky=NSEW)
rutinas = Label(root, text='Rutinas', fg=colort, bg=color, font=(None, 12, 'bold')).grid(row=5, column=1, columnspan=5, sticky=NW)
no1 = Label(root, text='Rutina No. 1', fg=colort, bg=color).grid(row=6, column=1, sticky=NSEW)
grabar1 = Button(root, text='Grabar', fg=colort, bg=colorb, activebackground=colorg).grid(row=6, column=3, sticky=NSEW)
play1 = Button(root, text='▶ / II', fg=colort, bg=colorb, activebackground=colorp, font=(None, 11, 'bold')).grid(row=6, column=5, sticky=NSEW)
no2 = Label(root, text='Rutina No. 2', fg=colort, bg=color).grid(row=8, column=1, sticky=NSEW)
grabar2 = Button(root, text='Grabar', fg=colort, bg=colorb, activebackground=colorg).grid(row=8, column=3, sticky=NSEW)
play2 = Button(root, text='▶ / II', fg=colort, bg=colorb, activebackground=colorp, font=(None, 11, 'bold')).grid(row=8, column=5, sticky=NSEW)
no3 = Label(root, text='Rutina No. 3', fg=colort, bg=color).grid(row=10, column=1, sticky=NSEW)
grabar3 = Button(root, text='Grabar', fg=colort, bg=colorb, activebackground=colorg).grid(row=10, column=3, sticky=NSEW)
play3 = Button(root, text='▶ / II', fg=colort, bg=colorb, activebackground=colorp, font=(None, 11, 'bold')).grid(row=10, column=5, sticky=NSEW)

mainloop()
