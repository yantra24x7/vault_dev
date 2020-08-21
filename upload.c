#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
#include <fwlib32.h>
#include <string.h>
#include <time.h>
#define LSIZ 100 
#define RSIZ 100
#define MAXLEN 1280
#define USHORT unsigned short


short mcPortNr = 8193;
int i,j,k,l;
unsigned short libHndl = 0;
short ret,rc,idx;
char machine_ip[20];
char prg1[500];
char base[2]="";
char line[RSIZ][LSIZ];
int tot = 0;
char **g_argv;


short down( void )
{

        FILE *readFile;
        char c;  
         long len, n;
        short ret;

	 readFile = fopen(g_argv[1], "rb");
	
        //FILE *readFile = fopen (filepath, "rb");
      if (readFile != NULL)
	{
	  if (cnc_dwnstart3 (libHndl, 0) == EW_OK)
	    {
	      long rc;
	      unsigned char buf[MAXLEN] = { 0 };
	      while (1)
		{
		  rc = fread (buf, sizeof (unsigned char), MAXLEN, readFile);
		  if (rc <= 0)
		    {
		      break;
		    }

		  do
		    {
		      ret = cnc_download3 (libHndl, &rc, (char *) buf);
		    }
		  while (ret == EW_BUFFER);

		  if (ret != EW_OK)
		    {
		      break;
		    }
		}
	      ret = cnc_dwnend3 ((short) libHndl);
	    }
	  fclose (readFile);
	}
    
  return ret;
}


int main(int argc, char *argv[])
{

    g_argv = argv;
    rc = cnc_startupprocess(3, "./fanuc.log");
    printf("\n rc<%d>/<%s> ", rc, rc == EW_OK ?  "ok" : "flr");
    sleep(1);
        for( i = 0; i <1; i++)
        {

            FILE *fptr = NULL; 
            int d = 0;
            fptr = fopen("machine_ip", "r");

            while(fgets(line[d], LSIZ, fptr)) 
            {
                line[d][strlen(line[d]) - 1] = '\0';    
                d++;
            }

            tot = d;

            sprintf(machine_ip,"%s%s",base,line[i]);
            printf("machine_ip=%s\n", machine_ip);

             rc = cnc_allclibhndl3( line[i], mcPortNr, 0,  &libHndl);
            if(rc =! EW_OK)
             {
              short d_own=down();
              printf("Ret=%s",d_own);
            
             }
            
}
}
