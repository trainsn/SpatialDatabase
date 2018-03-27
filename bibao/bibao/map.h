typedef vector< pair<string, string> > yilai;
class Database
{
public:
    int N; //属性集依赖关系的个数
    string R1; //属性集
    string R2; //所求的属性集
    yilai R3; //属性集依赖关系
    void R1shuru();
    void R2shuru();
    void R3shuru();
    bool ZFxiangdeng(char a, string b);
    bool ZFCbaohan(string a, string b);
    string bibao(string R2, yilai R3);
    string shuchuchuli(string X);
};