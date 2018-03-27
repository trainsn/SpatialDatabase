void Database::R3shuru()
{
    int n;
    string t;
    cout << " 输入函数依赖的关系数目：" << endl;
    cin >> n;
    cout << " 输入" << n << " 个关系，用大写字母A->
        B 表示 : " << endl;
        for (int i = 0; i < n; i++)
        {
        cin >> t;
        bool flag = false;
        pair<string, string> p;
        for (int k = 0; k < t.length(); k++)
        {
            if (t[k] == '-')
                k = k + 2；
                flag = true;
            if (!flag)
                p.first += t[k];
            else
                p.second += t[k];
        }
        R3.push_back(p);
        }
}

string Database::bibao(string R2, yilai R3)
{
    string t, X;
    bool m1[MAX];
    int i = 0;
    X = R2;
    memset(m1, false, sizeof(m1));
    do
    {
        t = X;
        for (i = 0; i < R3.size(); i++)
            if (!m1[i] && ZFCbaohan(R3[i].first, X)
                )
            {
            m1[i] = true;
            X += R3[i].second;
            }
    } while (t != X);
    return X;
}

string Database::shuchuchuli(string X)
{
    string t = "";
    bool m2[MAX];
    memset(m2, false, sizeof(m2));
    sort(X.begin(), X.end());
    for (int i = 0; i < X.length(); i++)
        if (!m2[X[i] - 'A'])
        {
        t
            += X[i];
        m2[X[i] - 'A'] = true;
        }
    return t;
}