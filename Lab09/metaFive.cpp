#include <bits/stdc++.h>
#define PI (acos(0)*2)
#define width 30
#define edge 5
#define step 2
using namespace std;



pair<int,int> rot(pair<int,int> center, pair<int,int> pt, double rad){
    pair<double,double> delta(pt.first-center.first,pt.second-center.second);
    return pair<int,int>(
        abs(center.first+delta.first*cos(rad)-delta.second*sin(rad)),
        abs(center.second+delta.first*sin(rad)+delta.second*cos(rad))
    );
}

void switchSide(vector<vector<int> >& mat
              ,pair<int,int> l, pair<int,int> r){

    if(l>r) swap(l,r);
    r.first-=l.first;
    r.second-=l.second;
    for(int row=0;row<width;row++)
    for(int col=0;col<width;col++){
        pair<int,int> delta(row-l.first,col-l.second);
        if(delta.first*r.second-delta.second*r.first<=0){
            mat[row][col]=!mat[row][col];
        }
    }
    return;
}

int main(){
    fstream fout("fiveStar.txt",ios::out);
    vector<vector<int> >mat(width+1,vector<int>(width+1,0));
    vector<pair<int,int> > collect;
    pair<int,int> center(width/2,width/2);
    collect.push_back(pair<int,int>(0,width/2));
    for(int cnt=1;cnt<edge;cnt++)
        collect.push_back(rot(center,collect.back(),PI*2/edge));


    int cnt2=0;
    for(int cnt=0;cnt<collect.size();cnt++,(cnt2+=step)%=collect.size())
        switchSide(mat,collect[cnt2],collect[(cnt2+step)%collect.size()]);

    for(int row=0;row<width;row++){
        fout<<width<<"'b ";
        for(int col=0;col<width;col++)
            fout<<mat[row][col];
        fout<<",\n";
    }

    fout.close();
    return 0;
}
