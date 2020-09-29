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
char buf[100];
void file_write();


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
	  if (ret=cnc_dwnstart3 (libHndl, 0) == EW_OK)
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
		      //printf("\n cnc_download rc<%d>/<%s> ", ret, ret == EW_OK ?  "ok" : "flr");
		      
		    }
		  while (ret == EW_BUFFER);

		  if (ret != EW_OK)
		    {
		      break;
		    }
		}
	      ret = cnc_dwnend3 ((short) libHndl);
	      printf("\n down endrc<%d>/<%s> ", ret, ret == EW_OK ?  "ok" : "flr");
	      if (ret == 5)
		    {
		      printf("\nProgram number already exist in cnc Machine");
		      sprintf(buf, "%s" , "Program number already exist in cnc Machine");
		      file_write();
		    }
		    
	      else
	      {
		printf("Program transferred to CNC\n");
		sprintf(buf, "%s" , "Program transferred to CNC");
		file_write();
		
	      }
	    }
	  fclose (readFile);
	 // printf("\n down_startrc<%d>/<%s> ", ret, ret == EW_OK ?  "ok" : "flr");
	}
    
  return ret;
}

void file_write()
{
  	FILE *fptr1;
	fptr1 = fopen("Error.txt","w");
	fprintf(fptr1,"%s",buf);
	printf("\nError_written_to_file_sucessfully\n");
	fclose(fptr1);
}


int main(int argc, char *argv[])
{

    g_argv = argv;
    rc = cnc_startupprocess(3, "./fanuc.log");
    if(rc)
    //printf("\n rc<%d>/<%s> ", rc, rc == EW_OK ?  "ok" : "flr");
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
	     printf("\n rc<%d>/<%s> ", rc, rc == EW_OK ?  "ok" : "flr");
            if(rc == EW_OK)
             {
              short d_own=down();
	      //printf("hello");
              //printf("Ret=%s",d_own);
              
             }
	    
	    else if(rc==-16)
	      {
		//printf("\n rc<%d>/<%s> ", rc, rc == EW_OK ?  "ok" : "flr");
		  printf("\nProgram download from cnc");
		  sprintf(buf, "%s" , "Program download from cnc");
		  file_write();
		  //printf("File_written1\n");
	      }
		else
		{
		printf("\nProgram not transfer");
		sprintf(buf, "%s" , "Program not transfer");
		file_write();
	      }
}
}

