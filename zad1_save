#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pwd.h>
#include <grp.h>
#include <dirent.h>
#include <limits.h>
#include <sys/stat.h>
#include <errno.h>

#define BUFSIZE 1024

///////////////////////////////////////////////////////////////////////////////////////////////////////
// string functions

void read_string(char *str, int num, FILE *stream) {
    if (fgets(str, num, stream) == NULL) {
        fprintf(stderr, "read error\n");
        exit(1);
    }
    str[strcspn(str, "\r\n")] = '\0';
}


void safe_strcpy(char* str_to, size_t str_to_buffer_size, const char* str_from) {
    if (str_to_buffer_size <= strlen(str_from)) {
        fprintf(stderr, "buffer too short\n");
        exit(1);
    }
    strcpy(str_to, str_from);
}


void safe_strcat(char* str_to, size_t str_to_buffer_size, const char* str_from) {
    if (str_to_buffer_size <= strlen(str_to) + strlen(str_from)) {
        fprintf(stderr, "buffer too short\n");
        exit(1);
    }
    strcat(str_to, str_from);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// user authorisation functions

static struct pam_conv login_conv = {
        misc_conv,
        NULL
};


void user_auth_error(pam_handle_t *pamh, int pam_status) {
    fprintf(stderr, "User authorisation error - try again\n");
    pam_end(pamh, pam_status);
}


void verify_user() {
    pam_handle_t* pamh;
    int ret_val;
    char *username;

    bool logged_in = false;

    while (!logged_in) {
        pamh = NULL;
        username = NULL;
        
        ret_val = pam_start("login", username, &login_conv, &pamh);
        if (pamh == NULL || ret_val != PAM_SUCCESS) {
            user_auth_error(pamh, ret_val);
            continue;
        }

        ret_val = pam_authenticate(pamh, 0);
        if (ret_val != PAM_SUCCESS) {
            user_auth_error(pamh, ret_val);
            continue;
        }
        printf("password ok\n");

        ret_val = pam_get_item(pamh, PAM_USER, (const void **) &username);
        if (ret_val != PAM_SUCCESS) {
            user_auth_error(pamh, ret_val);
            continue;
        }

        struct passwd *user_info = getpwnam(username);
        if (user_info == NULL) {
            user_auth_error(pamh, ret_val);
            continue;
        }

        struct group *officers_group = getgrnam("officers");
        if (user_info->pw_gid != officers_group->gr_gid) {
            printf("user not in officers group\n");
            user_auth_error(pamh, ret_val);
            continue;
        }

        time_t current_time = time(0);

        char time_str[100];
        sprintf(time_str, "%ld", current_time);

        char time_msg[200];
        strcpy(time_msg, "current time: ");
        strcat(time_msg, time_str);
        printf("%s\n", time_msg);

        printf("Enter current time: ");

        long user_input;
        char user_input_str[BUFSIZE];
        read_string(user_input_str, BUFSIZE, stdin);
        user_input = strtol(user_input_str, NULL, 10);

        if (labs(user_input - current_time) > 15) {
            ret_val = PAM_CONV_ERR;
            user_auth_error(pamh, ret_val);
            continue;
        }
        printf("time ok\n");

        pam_end(pamh, ret_val);

        logged_in = true;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// file functions

void print_file_content(const char *file_path) {
    FILE *fptr = fopen(file_path, "r");
    if (fptr == NULL)
    {
        printf("Cannot open file \n");
        exit(0);
    }

    int c = fgetc(fptr);
    while (c != EOF)
    {
        printf ("%c", c);
        c = fgetc(fptr);
    }
    fclose(fptr);
}


bool is_user_file_owner(const char *username, const char *file_path) {
    struct stat sb;
    stat(file_path, &sb);
    struct passwd *pw = getpwuid(sb.st_uid);

    if (strcmp(pw->pw_name, username) == 0) {
        return true;
    } else {
        return false;
    }
}

// Print filenames and file contents of files owned by @client_id in @dir_path directory.
void view_client_files(const char *client_id, const char *dir_path) {
    DIR *d;
    struct dirent *dir;
    char file_path[BUFSIZE];

    d = opendir(dir_path);
    printf("----------------------\n");
    printf("%s directory: \n\n", dir_path);
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            safe_strcpy(file_path, BUFSIZE, dir_path);
            safe_strcat(file_path, BUFSIZE, "/");
            safe_strcat(file_path, BUFSIZE, dir->d_name);

            if (is_user_file_owner(client_id, file_path)) {
                printf(" file: %s\n", dir->d_name);
                print_file_content(file_path);
            }
        }
        closedir(d);
    }
    printf("----------------------\n");
}


void view_client_deposits_and_credits(const char *client_id) {
    char dir_path[BUFSIZE];

    printf("----------------------\n");
    printf("view client files\n");

    safe_strcpy(dir_path, BUFSIZE, "./deposits");
    view_client_files(client_id, dir_path);

    safe_strcpy(dir_path, BUFSIZE, "./credits");
    view_client_files(client_id, dir_path);
}

// Create file with name from stdin in @dir_path directory. Set @client_id as file owner.
void create_file(char *file_path, int file_path_buffer_size, const char *dir_path,
                 const char *client_id) {
    char file_name_str[BUFSIZE];
    bool file_name_chosen = false;

    while (!file_name_chosen) {
        printf("----------------------\n");
        printf("enter file name\n");

        read_string(file_name_str, BUFSIZE, stdin);

        safe_strcpy(file_path, file_path_buffer_size,dir_path);
        safe_strcat(file_path, file_path_buffer_size,"/");
        safe_strcat(file_path, file_path_buffer_size,file_name_str);

        if( access( file_path, F_OK ) == 0 ) {
            printf("file name already taken\n");
        } else {
            file_name_chosen = true;
        }
    }

    FILE *fPtr = fopen(file_path, "w");
    if(fPtr == NULL) {
        fprintf(stderr, "Unable to create file.\n");
        exit(1);
    }
    fclose(fPtr);

    struct passwd *user_info = getpwnam(client_id);
    if (chown(file_path, user_info->pw_uid, user_info->pw_gid) == -1) {
        fprintf(stderr, "chown fail. %s\n", strerror(errno));
        exit(1);
    }

    printf("file created\n");
    printf("----------------------\n");
}


void write_to_file(const char *file_path, const char *data) {
    FILE *fPtr = fopen(file_path, "a");
    if(fPtr == NULL) {
        fprintf(stderr, "Unable to create file.\n");
        exit(1);
    }
    fputs(data, fPtr);
    fclose(fPtr);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// get user input functions

void choose_client(char *client_id, int client_id_buffer_size) {
    bool client_chosen = false;

    while (!client_chosen) {
        printf("----------------------\n");
        printf("enter client id\n");
        read_string(client_id, client_id_buffer_size, stdin);
        struct passwd *user_info = getpwnam(client_id);

        if (user_info == NULL) {
            printf("Incorrect username. Try again.\n");
            continue;
        }

        struct group *clients_group = getgrnam("clients");
        if (user_info->pw_gid != clients_group->gr_gid) {
            printf("User not in clients group.  Try again.\n");
            continue;
        }

        client_chosen = true;
    }

    printf("client chosen: %s\n", client_id);
    printf("----------------------\n");
}


unsigned long enter_amount() {
    unsigned long amount;
    char menu_choice_str[BUFSIZE];

    printf("----------------------\n");
    printf("enter the amount\n");

    read_string(menu_choice_str, BUFSIZE, stdin);
    amount = strtoul(menu_choice_str, NULL, 10);
    printf("amount chosen: %lu\n", amount);
    printf("----------------------\n");

    return amount;
}


struct tm enter_date() {
    unsigned long day, month, year;
    struct tm tm;
    char menu_choice_str[BUFSIZE];
    char *next_ptr;

    printf("----------------------\n");
    printf("enter date dd.mm.yyyy\n");

    bool correct_date = false;

    while (!correct_date) {
        read_string(menu_choice_str, BUFSIZE, stdin);
        day = strtoul(menu_choice_str, &next_ptr, 10);
        next_ptr++;
        month = strtoul(next_ptr, &next_ptr, 10);
        next_ptr++;
        year = strtoul(next_ptr, NULL, 10);

        if (day >= 1 && day <= 31 && month >= 1 && month <= 12
            && year >= 1900 && year <= INT_MAX) {
            correct_date = true;
        } else {
            printf("incorrect date\n");
            printf("enter date dd.mm.yyyy\n");
        }
    }

    tm.tm_sec = 0;
    tm.tm_min = 0;
    tm.tm_hour = 0;
    tm.tm_mday = (int) day;
    tm.tm_mon = (int) (month - 1);
    tm.tm_year = (int) year - 1900;

    printf("date chosen: %02d.%02d.%d\n", tm.tm_mday, tm.tm_mon + 1, tm.tm_year + 1900);
    printf("----------------------\n");

    return tm;
}


unsigned long enter_interest_rate() {
    unsigned long interest_rate;
    char interest_rate_str[BUFSIZE];

    printf("----------------------\n");
    printf("enter interest rate\n");

    read_string(interest_rate_str, BUFSIZE, stdin);
    interest_rate = strtoul(interest_rate_str, NULL, 10);
    printf("interest rate chosen: %lu%%\n", interest_rate);
    printf("----------------------\n");

    return interest_rate;
}


void add_new_sum(const char *file_path) {
    unsigned long amount = enter_amount();
    struct tm tm = enter_date();
    unsigned long interest_rate = enter_interest_rate();

    char data[BUFSIZE];
    char buffer[BUFSIZE];

    safe_strcpy(data, BUFSIZE, "Sum: ");
    sprintf(buffer, "%lu\n", amount);
    safe_strcat(data, BUFSIZE, buffer);

    safe_strcat(data, BUFSIZE, "Date: ");
    sprintf(buffer, "%02d.%02d.%d\n", tm.tm_mday, tm.tm_mon + 1, tm.tm_year + 1900);
    safe_strcat(data, BUFSIZE, buffer);

    safe_strcat(data, BUFSIZE, "Procent: ");
    sprintf(buffer, "%lu\n", interest_rate);
    safe_strcat(data, BUFSIZE, buffer);

    write_to_file(file_path, data);
}


void choose_deopsits_or_credits_directory(char *dir_path) {
    long int menu_choice;
    char menu_choice_str[BUFSIZE];

    bool correct_option = false;

    while (!correct_option) {
        printf("----------------------\n");
        printf("choose deposits or credits\n");
        printf("1. deposits\n");
        printf("2. credits\n");
        printf("----------------------\n");


        read_string(menu_choice_str, BUFSIZE, stdin);
        menu_choice = strtol(menu_choice_str, NULL, 10);

        if (menu_choice == 1 || menu_choice == 2) {
            correct_option = true;
        } else {
            printf("choose options 1-2\n");
        }

        if (menu_choice == 1) {
            safe_strcpy(dir_path, BUFSIZE, "./deposits");
            printf("deposits chosen\n");
        } else if (menu_choice == 2) {
            safe_strcpy(dir_path, BUFSIZE, "./credits");
            printf("credits chosen\n");
        }
    }
    printf("----------------------\n");
}

// Choose file in @dir_path directory from files owned by @client_id.
void choose_file(char *file_path, const char *dir_path, const char *client_id) {
    char file_name_str[BUFSIZE];
    bool file_chosen = false;

    while (!file_chosen) {
        printf("----------------------\n");
        printf("client files\n");
        view_client_files(client_id, dir_path);
        printf("----------------------\n");
        printf("enter file name\n");
        printf("----------------------\n");

        read_string(file_name_str, BUFSIZE, stdin);

        safe_strcpy(file_path, BUFSIZE,dir_path);
        safe_strcat(file_path, BUFSIZE,"/");
        safe_strcat(file_path, BUFSIZE,file_name_str);

        if( access( file_path, F_OK ) == 0 ) {
            if (is_user_file_owner(client_id, file_path)) {
                file_chosen = true;
            } else {
                printf("File not owned by user. Try again.\n");
            }
        } else {
            printf("File does not exist. Try again.\n");
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// deposits/credits create/modify functions

void add_deposit_or_credit(const char *client_id) {
    char dir_path[BUFSIZE];
    choose_deopsits_or_credits_directory(dir_path);

    char file_path[BUFSIZE];
    create_file(file_path, BUFSIZE, dir_path, client_id);

    char data[BUFSIZE];
    safe_strcpy(data, BUFSIZE, "Name: ");
    struct passwd *user_info = getpwnam(client_id);
    safe_strcat(data, BUFSIZE, user_info->pw_gecos);
    safe_strcat(data, BUFSIZE, "\nNumber: 1\n");
    write_to_file(file_path, data);

    add_new_sum(file_path);
}


void change_interest(const char *file_path) {
    printf("enter end date\n");
    struct tm tm1 = enter_date();
    unsigned long interest_rate = enter_interest_rate();
    printf("enter start date\n");
    struct tm tm2 = enter_date();

    char data[BUFSIZE];
    char buffer[BUFSIZE];

    safe_strcpy(data, BUFSIZE, "Date: ");
    sprintf(buffer, "%02d.%02d.%d\n", tm1.tm_mday, tm1.tm_mon + 1, tm1.tm_year + 1900);
    safe_strcat(data, BUFSIZE, buffer);

    safe_strcat(data, BUFSIZE, "Procent: ");
    sprintf(buffer, "%lu\n", interest_rate);
    safe_strcat(data, BUFSIZE, buffer);

    safe_strcat(data, BUFSIZE, "Date: ");
    sprintf(buffer, "%02d.%02d.%d\n", tm2.tm_mday, tm2.tm_mon + 1, tm2.tm_year + 1900);
    safe_strcat(data, BUFSIZE, buffer);

    write_to_file(file_path, data);
}


void add_end_date(const char *file_path) {
    printf("enter end date\n");
    struct tm tm = enter_date();

    char data[BUFSIZE];
    char buffer[BUFSIZE];

    safe_strcpy(data, BUFSIZE, "Date: ");
    sprintf(buffer, "%02d.%02d.%d\n", tm.tm_mday, tm.tm_mon + 1, tm.tm_year + 1900);
    safe_strcat(data, BUFSIZE, buffer);

    write_to_file(file_path, data);
}


void modify_deposits_or_credits(const char *client_id) {
    long int menu_choice;
    char menu_choice_str[BUFSIZE];
    char file_path[BUFSIZE];

    char dir_path[BUFSIZE];
    choose_deopsits_or_credits_directory(dir_path);
    printf("----------------------\n");
    printf("choose file to modify\n");
    choose_file(file_path, dir_path, client_id);

    bool exit = false;
    while (!exit) {
        printf("----------------------\n");
        printf("Menu\n");
        printf("1. add new sum\n");
        printf("2. change interest\n");
        printf("3. enter end date\n");
        printf("4. exit to main menu\n");
        printf("----------------------\n");

        read_string(menu_choice_str, BUFSIZE, stdin);
        menu_choice = strtol(menu_choice_str, NULL, 10);

        if (menu_choice == 1) {
            add_new_sum(file_path);
        } else if (menu_choice == 2) {
            change_interest(file_path);
        } else if (menu_choice == 3) {
            add_end_date(file_path);
        } else if (menu_choice == 4) {
            exit = true;
        } else {
            printf("choose options 1-4\n");
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
// menu and main

_Noreturn void run_menu() {
    long int menu_choice;
    char menu_choice_str[BUFSIZE];
    char client_id[BUFSIZE];
    choose_client(client_id, BUFSIZE);

    while (true) {
        printf("----------------------\n");
        printf("Menu\n");
        printf("1. choose client\n");
        printf("2. view deposits and credits\n");
        printf("3. add deposit or credit\n");
        printf("4. modify deposits or credits\n");
        printf("----------------------\n");

        read_string(menu_choice_str, BUFSIZE, stdin);
        menu_choice = strtol(menu_choice_str, NULL, 10);

        if (menu_choice == 1) {
            choose_client(client_id, BUFSIZE);
        } else if (menu_choice == 2) {
            view_client_deposits_and_credits(client_id);
        } else if (menu_choice == 3) {
            add_deposit_or_credit(client_id);
        } else if (menu_choice == 4) {
            modify_deposits_or_credits(client_id);
        } else {
            printf("choose options 1-4\n");
        }
    }
}


int main () {
    verify_user();
    run_menu();
    exit(0);
}
