#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
#include <fwlib32.h>
#include <string.h>
#include <time.h>
#include <curl/curl.h>

#define LSIZ 100 
#define RSIZ 100

short mcPortNr = 8193;
int i,j,k,l;
unsigned short libHndl = 0;
short ret,rc,idx;
struct odbpro prgnum;
int i,j,k,l;
#define BUFSIZE 1280

char machine_ip[20];
char prg1[500];
char base[2]="";
char line[RSIZ][LSIZ];
int tot = 0;
char **g_argv;



short upload( long prgnum )
{
        char buf[BUFSIZE+1] ;
        short ret ;
        long len ;
        ret = cnc_upstart3( libHndl, 0, prgnum, prgnum ) ;
        if ( ret ) 
		return ( ret ) ;
		
        do {


		
	FILE *fptr1;
	fptr1 = fopen(g_argv[1],"w");

                len = BUFSIZE ;
                ret = cnc_upload3( libHndl, &len, buf ) ;
                if ( ret == EW_BUFFER ) {
                        continue ;
                }
                if ( ret == EW_OK ) {
                        buf[len] = '\0' ;
		fprintf(fptr1,"%s",buf);
	             fclose(fptr1);
                      //  printf( " \n %s \n", buf ) ;
                }
                if ( buf[len-1] == '%' ) {
                        break ;
                }
        }
		while(( ret == EW_OK ) || ( ret == EW_BUFFER ));
        ret = cnc_upend3( libHndl) ;
        return ( ret ) ;
}

int main(int argc, char *argv[])
{

	g_argv = argv;
		int conv_prg;
                   
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
		fclose(fptr);
            printf("ip\n");

			if (rc == EW_OK)

			{ 
				
				rc = cnc_rdprgnum(libHndl, &prgnum);
					//printf("\nprgnu=%d\n",prgnum);
				//prgnum=O2270;
				if (rc != EW_OK)
					break;
			}

			

 else if(rc==-17)

			{
			printf("\nRasbperrypi will Reboot with in a sec.......");
		    sleep(3);
		    system("systemctl reboot -i");
			} 
			
			
			int programe_number[ FILENAME_MAX ];
			//short programee_number = prgnum.mdata;
				conv_prg = atoi(argv[2]); 
			short programee_number = conv_prg ;
			 printf("programee_number=%d \n",programee_number);
			short up_load=upload(programee_number);
			 printf("Ret=%d",up_load);
			 }

}