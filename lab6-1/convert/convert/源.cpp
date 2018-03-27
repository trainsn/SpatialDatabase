#include<stdio.h>
#include <stdlib.h>
void main(){
    FILE *fp;
    char str[150],ch;
    int j, k;
    if ((fp = fopen("e:\\basket.txt", "rt")) == NULL){
        printf("\nCannot open file strike any key exit!");
        //getch();
        exit(1);
    }
    freopen("e:\\basket_convert.txt", "w", stdout);
    
    while (!feof(fp))
    {
        //ch = fgetc(fp);
        fgets(str, 149, fp);
        for (j = k = 0; str[j] != '\0'; j++)
            if (str[j] != '\n')
                str[k++] = str[j];
        str[k] = '\0';
        printf("\'%s\'\n", str);
    }    
    fclose(fp);
}