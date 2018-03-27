#include<iostream>
#include<string>
#include<algorithm>
#include<vector>
#include<stdio.h>
using namespace std;

string R; //关系模式
vector< pair<string, string> > F; // 函数依赖集（FD)
vector<string>subset; //关系模式 R 的所有子集
char *temp; //求所有子集的辅助变量
vector<string>candidate_key; // 所有的候选键
vector<string>super_key; //所有的超键

/*********************************************************************/
bool _includes(string s1, string s2){ //判断 s2 的每个元素是否都存在于 s1
    sort(s1.begin(), s1.end());
    sort(s2.begin(), s2.end());
    return includes(s1.begin(), s1.end(), s2.begin(), s2.end()); // includes函数是基于有序集合的，所以先排序
}
string get_attribute_closure(const string &X, const vector< pair<string, string> > &F){ //返回属性集X的闭包
    string ans(X); //初始化 ans
    string temp;
    bool *vis = new bool[F.size()];
    fill(vis, vis + F.size(), 0);
    do{
        temp = ans;
        for (int i = 0; i != F.size(); ++i){
            if (!vis[i] && _includes(ans, F[i].first)){
                vis[i] = 1;
                ans += F[i].second;
            }
        }
    } while (temp != ans); // ans 无任何改变时终止循环

    delete[]vis;
    vis = NULL;
    //删掉重复的
    sort(ans.begin(), ans.end());
    ans.erase(unique(ans.begin(), ans.end()), ans.end());
    return ans;
}
void _all_subset(int pos, int cnt, int num){ // get_all_subset()的辅助函数
    if (num <= 0){
        temp[cnt] = '\0';
        subset.push_back(temp);
        return;
    }
    temp[cnt] = R[pos];
    _all_subset(pos + 1, cnt + 1, num - 1);
    _all_subset(pos + 1, cnt, num - 1);
}
void get_all_subset(const string &R){ //求关系模式R的所有子集，保存在subset中
    subset.clear();
    temp = NULL;
    temp = new char[R.size()];
    _all_subset(0, 0, R.length());
    //delete[]temp;
    temp = NULL;
}
bool is_candidate_key(const string &s){ //判断 s 是否是候选键
    for (int i = 0; i != candidate_key.size(); ++i)
        if (_includes(s, candidate_key[i])) //如果s包含了已知的候选键，那么s就不是候选键
            return false;
    return true;
}

bool cmp_length(const string &s1, const string &s2){ //对 subset 以字符串长度排序
    return s1.length() < s2.length();
}
void get_candidate_key(const string &R, const vector< pair<string, string> > &F){//求关系模式 R基于F的所有候选键
    get_all_subset(R);
    sort(subset.begin(), subset.end(), cmp_length);
    candidate_key.clear();
    super_key.clear();
    for (int i = 0; i != subset.size(); ++i){
        if (_includes(get_attribute_closure(subset[i], F), R)){
            super_key.push_back(subset[i]);
            if (is_candidate_key(subset[i]))
                candidate_key.push_back(subset[i]);
        }
    }
}

typedef vector<pair<string, string> > vpss;
vpss get_minimum_rely(const vpss &F){ //返回 F 的依赖集
    vpss G(F);
    //使 G 中每个 FD 的右边均为单属性
    for (int i = 0; i != G.size(); ++i){
        if (G[i].second.length() > 1){
            string f = G[i].first, s = G[i].second, temp;
            G[i].second = s[0];
            for (int j = 1; j<s.length(); ++j){
                temp = s[j];
                G.push_back(make_pair(f, temp));
            }
        }
    }

    int MAXN = 0;
    for (int i = 0; i != G.size(); ++i)
        if (G[i].first.length()>MAXN)
            MAXN = G[i].first.length();
    bool *del = new bool[MAXN];

    //在 G 的每个 FD 中消除左边冗余的属性
    for (int i = 0; i != G.size(); ++i){
        if (G[i].first.length() > 1){
            fill(del, del + G[i].first.length(), 0);
            for (int j = 0; j != G[i].first.length(); ++j){ //对于第i个FD,判断是否可消除first的第j个属性
                string temp;
                del[j] = 1;
                for (int k = 0; k != G[i].first.length(); ++k)
                    if (!del[k])
                        temp += G[i].first[k];
                if (!_includes(get_attribute_closure(temp, G), G[i].second)) //不可删除
                    del[j] = 0;
            }
            string temp;
            for (int j = 0; j != G[i].first.length(); ++j)
                if (!del[j])
                    temp += G[i].first[j];
            G[i].first = temp;
        }
    }
    delete[]del;
    del = NULL;

    //必须先去重
    sort(G.begin(), G.end());
    G.erase(unique(G.begin(), G.end()), G.end());

    //在 G 中消除冗余的 FD
    vpss ans;
    for (int i = 0; i != G.size(); ++i){ //判断第i个 FD 是否冗余
        vpss temp(G);
        temp.erase(temp.begin() + i);
        if (!_includes(get_attribute_closure(G[i].first, temp), G[i].second)) //第 i 个 FD 不是冗余
            ans.push_back(G[i]);
    }
    return ans;
}
string _difference(string a, string b){ //先去重，再返回 a 和 b 的差集，即 a-b
    string c;
    c.resize(a.size());
    sort(a.begin(), a.end());
    a.erase(unique(a.begin(), a.end()), a.end());
    sort(b.begin(), b.end());
    string::iterator It = set_difference(a.begin(), a.end(), b.begin(), b.end(), c.begin());
    c.erase(It, c.end());
    return c;
}
/***************将关系模式 R  无损分解成 BCNF 模式集 *****************/
vector<string> split_to_bcnf(const string &R, const vector< pair<string, string> > &F){
    vector<string> ans;
    vector<string> temp;
    ans.push_back(R);
    vector< pair<string, string> > FF = get_minimum_rely(F); //保存 F的最小依赖集到 FF
    int flag;
    do{
        flag = 0;
        temp.resize(ans.size());
        temp.assign(ans.begin(), ans.end()); //保存当前的 ans

        for (int i = 0; i != ans.size(); ++i){
            vector< pair<string, string> > MC;// 求 ans[i] 上的最小依赖集
            for (int j = 0; j != FF.size(); ++j){
                if (_includes(ans[i], FF[j].first) && _includes(ans[i], FF[j].second))
                    MC.push_back(FF[j]);
            }
            sort(MC.begin(), MC.end());
            MC.erase(unique(MC.begin(), MC.end()), MC.end());

            get_candidate_key(ans[i], MC);
            for (int j = 0; j != MC.size(); ++j){
                int is_super_key = 0;
                for (int k = 0; k != super_key.size(); ++k){
                    if (_includes(MC[j].first, super_key[k])){
                        is_super_key = 1;
                        break;
                    }
                }
                // ans[i]中存在一个非平凡 FD x->y, 有 x 不包含超键，就把 ans[i]
                //分解成 xy 和 ans[i]-y ;
                if (!is_super_key){
                    ans.push_back(_difference(ans[i], MC[j].second));
                    ans[i] = MC[j].first + MC[j].second;
                    flag = 1;
                    break;
                }
            }
            if (flag)
                break;
        }
        /********当 ans 没有改变时终止循环，否则会出现死循环 **********/
        sort(temp.begin(), temp.end());
        sort(ans.begin(), ans.end());
        temp.erase(unique(temp.begin(), temp.end()), temp.end());
        ans.erase(unique(ans.begin(), ans.end()), ans.end());
        if (equal(ans.begin(), ans.end(), temp.begin()))
            break;
    } while (flag);
    return ans;
}

/********************************************************************/

void init(){ //初始化
    R = "";
    F.clear();
}
void inputR(){   //输入关系模式 R
    cout << "请输入关系模式 R:" << endl;
    cin >> R;
}
void inputF(){  //输入函数依赖集 F
    int n;
    string temp;
    cout << "请输入函数依赖的数目：" << endl;
    cin >> n;
    cout << "请输入" << n << "个函数依赖：(输入形式为 a->b ab->c) " << endl;
    for (int i = 0; i < n; ++i){
        pair<string, string>ps;
        cin >> temp;
        int j;
        for (j = 0; j != temp.length(); ++j){ //读入 ps.first
            if (temp[j] != '-'){
                if (temp[j] == '>')
                    break;
                ps.first += temp[j];
            }
        }
        ps.second.assign(temp, j + 1, string::npos); //读入 ps.second
        F.push_back(ps); //读入ps
    }
}
/**************************************************************************/
int main(){
    //freopen("in.txt", "r", stdin);
    init();
    inputR();
    inputF();

    vector<string> ans = split_to_bcnf(R, F);
    cout << "将关系模式 R 无损分解成 BCNF 模式集，如下：" << endl;
    for (int i = 0; i != ans.size(); ++i)
        cout << ans[i] << endl;
    system("pause");
    return 0;
}