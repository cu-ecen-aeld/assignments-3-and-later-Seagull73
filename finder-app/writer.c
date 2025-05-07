#include <stdio.h>
#include <syslog.h>
#include <string.h>

#define STR_BUFFER_SIZE    256

int main(int argc, char *argv[])
{
    int err_num = 0;
    char file_path[STR_BUFFER_SIZE];
    char target_str[STR_BUFFER_SIZE];
    openlog("SysLog", LOG_CONS | LOG_PID | LOG_PERROR, LOG_USER);

    switch (argc)
    {
        case 1:
            /* File not Specified */
            syslog(LOG_ERR , "File not specified!");

            err_num = 1;

            break;

        case 2:
            /* String not Specified */
            syslog(LOG_ERR , "String not specified!");

            err_num = 1;

            break;

        case 3:
            /* Normal */
            strncpy(file_path, argv[1], STR_BUFFER_SIZE - 1);
            strncpy(target_str, argv[2], STR_BUFFER_SIZE - 1);

            err_num = 0;

            break;

        default:
            /* Wrong Argument Number */
            syslog(LOG_ERR , "Wrong Argument Numbers!");

            err_num = 1;

            break;

    }

    if (err_num == 0)
    {
        /* Write to File */
        FILE *fptr = fopen(file_path, "w");

        fprintf(fptr, "%s", target_str);

        fclose(fptr);

        /* Write to Log */
        char log_str[STR_BUFFER_SIZE] = "";

        strcat(log_str, "Writing ");
        strcat(log_str, target_str);
        strcat(log_str, " to ");
        strcat(log_str, file_path);

        syslog(LOG_DEBUG, "%s", log_str);
    }

    closelog();

    return err_num;
}
