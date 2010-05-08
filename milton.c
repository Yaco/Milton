
/*
milton - Programa para capturar slides y generar una tabla de tiempos
por Franco Iacomella - bajo GNU GPL.

Requiere el paquete 'scrot' para generar las capturas.

Basado en uberkey gurkan@linuks.mine.nu, www.linuks.mine.nu/uberkey/
*/

#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/param.h>

#ifdef BSD
#include <stdio.h>
#include <err.h>
#include <machine/sysarch.h>
#include <machine/cpufunc.h>
#else
#include <sys/io.h>
#endif

char translate[128]     ="  1234567890-=\b\tqwertyuiop[]\n asdfghjkl;'   zxcvbnm,./ *                                                                       ";
char translateshift[128]="  +\"*ç%&/()=?`\b\tQWERTYUIOPè!\n ASDFGHJKL;'   ZXCVBNM;:_ *                                                                       ";
char keytable[128];


char mouseoff[200] ="gconftool-2 --type boolean --set /desktop/gnome/peripherals/mouse/touchpad_enabled false && synclient TouchpadOff=1 && sleep 1s && synclient TouchpadOff=1";

char mouseon[100] ="synclient TouchpadOff=0";


int apagado = 1;

int nomouse() 
{
	if (apagado == 1) {
		system(mouseon);
		apagado = 0;	
	} else {
		system(mouseoff);
		apagado = 1;
	}

}

int delay()
{
	time_t start;
	time_t current;

	time(&start);

	printf("En 10 segundos comienza la captura de diapositivas y se deshabilita el touchpad. Para reactivarlo usar F12. \n");
	do{
	time(&current);
	}while(difftime(current,start) < 10.0);
	


	
	system(mouseoff);
	apagado = 1;	

	printf("Comenzo!!.\n");
	return 0;
}




int main(int argc, char** argv)
{

    if (getuid()!=0) {
	printf("Corre el programa usando sudo.\n");
	return 1;
    }

 if (argc != 2)
  {
        //el primer parametro es help
        printf("Indique como argumento el nombre de la carpeta donde se guardaran las capturas.\r\n     Ejemplo: milton <carpeta>\n");
	exit(0);
  }

    /* iopl()
       inb() */
    struct timespec test;
	time_t inicio = 0;    
	time_t ahora = 0;	
	int tiempo = 0;

	delay();

	char carpeta[100];
	sprintf(carpeta,"mkdir %s",argv[1]);
	system(carpeta);


	char comando[100];
	sprintf(comando,"scrot %s/slide-%05d.png",argv[1],tiempo);


	unsigned char c,shift;

    
    test.tv_sec=0;
    test.tv_nsec=1;

    for (c=shift=0; c<127; c++) keytable[c]=0;
    
#ifdef BSD
    if (i386_set_ioperm(0x60,5,1) == -1)
	err(1,"i386_set_ioperm failed");
#else	
    iopl(3);
#endif
	inicio = time(NULL);
	
    while(1) {
	while((inb(0x64)&32)); /* fix ps/2 mouse interference */
	c=inb(0x60);
	ahora = time(NULL);
	tiempo = (int) ahora - (int) inicio;

        if (c<128) {
    	    if (keytable[c]!=1) {
		sprintf(comando,"scrot %s/slide-%05d.png",argv[1],tiempo);
		switch (c) {
		   case 14: printf("%d <backspace>\n", tiempo);system(comando); break;
		   case 71: printf("%d <home>\n", tiempo);system(comando); break;
		   case 79: printf("%d <end>\n", tiempo);system(comando); break;
		   case 73: printf("%d <pgup>\n", tiempo);system(comando); break;
		   case 81: printf("%d <pgdn>\n", tiempo);system(comando); break;
		   case 72: printf("%d <up>\n", tiempo);system(comando); break;
		   case 80: printf("%d <down>\n", tiempo);system(comando); break;
		   case 75: printf("%d <left>\n", tiempo);system(comando); break;
		   case 77: printf("%d <right>\n", tiempo);system(comando); break;		   
		   case 63: printf("%d <f5>\n", tiempo);system(comando); break;
		   case 67: printf("%d <f9>\n", tiempo);system(comando); break;
		

		   case 88: nomouse(); break;

/*
		   case 1: printf("%d <esc>\n", tiempo); break;

		   case 15: printf("%d <tab>\n", tiempo); break;
		   case 28: printf("%d \n", tiempo);  break;
		   case 42: printf("%d <shift-l>\n", tiempo); shift=1; break;
		   case 54: printf("%d <shift-r>\n", tiempo); shift=1; break;
		   case 29: printf("%d <ctrl>\n", tiempo); break;
		   case 56: printf("%d <alt>\n", tiempo); break;
		   case 82: printf("%d <ins>\n", tiempo); break;
		   case 83: printf("%d <del>\n", tiempo); break;

		   case 59: printf("%d <f1>\n", tiempo); break;
		   case 60: printf("%d <f2>\n", tiempo); break;
		   case 61: printf("%d <f3>\n", tiempo); break;
		   case 62: printf("%d <f4>\n", tiempo); break;
		   case 64: printf("%d <f6>\n", tiempo); break;
		   case 65: printf("%d <f7>\n", tiempo); break;
		   case 66: printf("%d <f8>\n", tiempo); break;
		   case 68: printf("%d <f10>\n", tiempo); break;
		   case 87: printf("%d <f11>\n", tiempo); break;
		   case 88: printf("%d <f12>\n", tiempo); break;

		   default: {
		      /*if (shift>0) {
    		         printf("%c",translateshift[c & 127]);
    		         /*printf("%d (%03i) ",c);
		      } else {
    		         printf("%c",translate[c & 127]);
    		         /*printf("%d (%03i) ",c);
		      }
		   }*/
		}
		fflush(0);
	    }
	    keytable[c]=1;
	} else {
	    keytable[c & 127]=0;
	    if (keytable[42]==0) if (keytable[54]==0) shift=0;
	}
	usleep(500);
	//nanosleep(&test,NULL);
    }

    return 0;
}
