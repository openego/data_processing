from sys import argv;
import MakeObjects;
from tkinter import filedialog,messagebox;

print(__name__)
def run():
    filename = filedialog.askopenfilename()
    myFile = filename.split('/')
    print("Executed Successfully!")
    fileNameLength = len(myFile)
    if fileNameLength <=1:
        print("Empty file")
        
        if messagebox.askyesno('Try Again',"You didn't selected the file, Retry?"):
            run()
    else:
        myFileName = myFile[-1]
        MakeObjects.execGraphmlFile(myFileName)
    #return myFileName
    
if __name__ == '__main__':
        run()
