clear
set more off
set mem 10000
*--------- Work station directory -------------*
cd "D:\Microsimulation"
*--------------------------------------------------------* 

*========================================================*
*=====================   BEGIN   ===========================*
*========================================================*

* bbbbbbbbbbbbbbbbbbbbbbbbbb*

*======================================*
*======  1. THUE THU NHAP CA NHAN  =======*
*======================================*
use "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\Muc4a.dta"

*------------------------------------------------------*
*-------------  1.1. THU NHAP ---------------*
*------------------------------------------------------*

******   1.1.1. Thu nhap tien luong tien cong   *********

* Co di lam nhan tien luong tien cong
gen wagejob1 = m4ac9
label var wagejob1 "Co nhan luong job1 khong"
recode wagejob1 . = 2
label define wagejobl 1 "Co" 2 "Khong" 
label value wagejob1 wagejobl

gen wagejob2 = m4ac21
label var wagejob2 "Co nhan luong job2 khong"
recode wagejob2 . = 2
label value wagejob2 wagejobl

gen wagejob3 = m4ac25
label var wagejob3 "Co nhan luong job3 khong"
recode wagejob3 . = 2
label value wagejob3 wagejobl

* Tien luong, tien cong theo nam
gen yearWage1 = m4ac11 if wagejob1 == 1
recode yearWage1 . = 0
gen yearWage2 = m4ac23 if wagejob2 == 1
recode yearWage2 . = 0
gen yearWage3 = m4ac26 if wagejob3 == 1
recode yearWage3 . = 0

egen yearWage = rsum(yearWage1 yearWage2 yearWage3)
label var yearWage "Tien luong tien cong 12 thang"

* Tien luong, tien cong 
gen wage1 = m4ac10 if wagejob1 == 1
recode wage1 . = 0
gen wage2 = m4ac22 if wagejob2 == 1
recode wage2 . = 0

// Uoc tinh thoi gian lam viec job1 //											
gen jobTime1= yearWage1 / wage1 if wage1 > 0
replace jobTime1 = 0 if wagejob1 == 2 									// so thang lam viec = 0 neu khong di lam cong 
label var jobTime1 "thoi gian lam viec job1 (thang)"
replace jobTime1 = 12 if jobTime1 > 12   								// so thang lam viec toi da 1 nam la 12 thang

// Uoc tinh thoi gian lam viec job2 //											
gen jobTime2 = yearWage2 / wage2 if wage2 > 0
replace jobTime2 = 0 if wagejob2 == 2 									// so thang lam viec = 0 neu khong di lam cong 
label var jobTime2 "thoi gian lam viec job2 (thang)"
replace jobTime2 = 12 if jobTime2 > 12   								// so thang lam viec toi da 1 nam la 12 thang

// Uoc tinh thoi gian lam viec job3 //		
gen jobTime3 = jobTime2 if wagejob3 == 1							//lay giong job2
replace jobTime3 = 12 if jobTime2 == 0 & wagejob3 == 1		//gia su job3 lam 12 thang neu job2 khong lam cong
replace jobTime3 = 0 if wagejob3 == 2
label var jobTime3 "thoi gian lam viec job3 (thang)"
replace jobTime3 = 12 if jobTime3 > 12

// Dung thoi gian de tinh luong thang job3 //
gen wage3 = yearWage3 / jobTime3 if jobTime3 > 0
recode wage3 . = 0

// Tong tien luong thang //
egen wage = rsum(wage1 wage2 wage3)
label var wage "Tien luong tien cong thang truoc"

* Tien thuong le tet 
gen yearGift1 = m4ac12a
recode yearGift1 . = 0
gen yearGift2 = m4ac24a
recode yearGift2 . = 0
egen yearGift = rsum(yearGift1 yearGift2) 
label var yearGift  "Tien Le tet trong nam"

* Tien thuong le tet theo thang
gen gift1 = yearGift1 / floor(jobTime1)
recode gift1 . = 0
gen gift2 = yearGift2 / floor(jobTime2)
recode gift2 . = 0
egen gift = rsum(gift1 gift2)
label var gift "Tien Le tet trong thang"

* Tien thuong khac (tinh thue) + dong phuc, an trua, om dau, tai nan (khong tinh thue) -> khong tach ra duoc -> assume khong tinh thue
gen bonus1 = m4ac12a
gen bonus2 = m4ac24b
egen bonus = rsum(bonus1 bonus2)
label var bonus "Tien phu cap khac"

* Thu nhap theo thang
egen income1 = rsum(wage gift bonus)
label var income1 "Thu nhap tien luong theo thang"
replace income1 = 0 if income1 < 0		// fix quan sat bi loi

gen income1T = income1					// thu bo "-bonus" xem co hop ly khong
label var income1T "Thu nhap tien luong tinh thue"
replace income1T =0 if income1T < 0  // cho chac thoi

*****************************************************************************************************************************************
gen double id = xa*10^7 + diaban*10^4 + hoso*10^2 + matv                                           // Tao id de merge voi file khac
drop if id == .
gen double idho = xa*10^7 + diaban*10^4 + hoso*10^2
drop if idho == .
*keep id idho tinh huyen xa diaban hoso matv  wage yearWage jobTime1 yearGift gift income1
keep id idho tinh huyen xa diaban hoso matv  income1 income1T jobTime1
order id idho , first
save "thunhap.dta", replace
*****************************************************************************************************************************************

***************   1.1.2. Thu nhap tu kinh doanh   **************

clear
use "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\Muc4C1.dta"
//---- Doanh thu tu kinh doanh trong nam
gen revenueYear  = m4c1c18
label var revenueYear "Doanh thu trong nam" 
recode revenueYear .=0
gen consumeYear = m4c1c14
label var consumeYear "Tieu dung trong nam"
recode consumeYear .=0
gen revenueNetYear = revenueYear - consumeYear 
label var revenueNetYear "Doanh thu thuan trong nam"

//---- Thoi gian kinh doanh
gen time = m4c1c3
label var time "Thoi gian kinh doanh"

//---- Tinh doanh thu thang
gen revenue = revenueNetYear / time
label var revenue "Doanh thu 1 thang"

//---- Loai hinh kinh doanh
gen bizType = m4c1c7
label var bizType "Loai hinh kinh doanh theo dang ky kinh doanh"
label define bizTypel 1 "Doanh nghiep" 2 "Ho kinh doanh" 3 "Ca the khong dang ky"
label value bizType bizTypel

//---- Nganh nghe kinh doanh
gen nganh = m4c1c2
gen  industry = .
replace industry = 1 if (nganh >= 45 & nganh <= 47) | nganh == 68
replace industry = 2 if (nganh >=55 & nganh <= 66) | (nganh >= 77 & nganh <= 82) | nganh == 94 | nganh == 96 | (nganh >= 41 & nganh <= 43)
replace industry = 3 if nganh == 95 | (nganh >=1 & nganh < 35) | (nganh >= 49 & nganh <= 53) 
recode industry . = 4
label define industryl 1 "Phan phoi, cung cap hang hoa" 2 "Dich vu, xay dung" 3 "San xuat, van tai, dich vu gan voi hang hoa" 4 "Kinh doanh khac"
label value industry industryl

//---- Thu nhap tu kinh doanh
//------------ Tao ID cua ho
gen double idho = xa*10^7 + diaban*10^4 + hoso*10^2
drop if idho == .
order idho , first

//------------ Tong thu nhap cua ho
bysort idho: egen incomekdtotal_year = total(revenueNetYear)
bysort idho: egen incomekdtotal = total(revenue)

//---- Thu nhap chiu thue tu kinh doanh 
//----------- Tren 100 trieu/nam phai dong thue
gen incomekdtotal_year_tax = incomekdtotal * 12			// xac dinh nguong nop thue dua tren thu nhap cac thang kinh doanh
recode incomekdtotal_year_tax .= 0
label var incomekdtotal_year_tax "thu nhap tu kinh doanh (12 thang) de xac dinh nguong nop thue"
gen thunhapcao = 0
replace thunhapcao = 1 if incomekdtotal_year_tax > 100000

//----------- Nganh kinh doanh cua ho (neu 1 ho co nhieu nganh thi dung nganh kinh doanh chinh)
gsort idho -revenue
by idho: gen stt = _n
gen industry_tem = industry if stt == 1
by idho: egen industryho = total(industry_tem)
label var industryho "Nganh nghe kinh doanh cua ho"
drop industry_tem stt

//----------- Thu nhap chiu thue = Doanh thu * Ty le thu nhap chiu thue theo nganh
gen incomekdho = 0
replace incomekdho = incomekdtotal * 7 /100 		if industryho == 1 & thunhapcao == 1
replace incomekdho = incomekdtotal * 30 /100 	if industryho == 2 & thunhapcao == 1
replace incomekdho = incomekdtotal * 15 /100 	if industryho == 3 & thunhapcao == 1
replace incomekdho = incomekdtotal * 12 /100 	if industryho == 4 & thunhapcao == 1

//---- Merge voi file thu nhap
collapse incomekdtotal incomekdho incomekdtotal_year_tax time, by(idho)	
recode incomekdtotal . = 0 
recode incomekdho . = 0
save "doanhthukd.dta", replace
merge m:m idho using "thunhap.dta", gen(merge_kd)
recode incomekdho . = 0
save "thunhap.dta", replace 

***************   1.1.3. Thu nhap khac   **************
* NOTE: Cac khoan thu nhap khac gom:
clear
use  "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\Muc4D.dta"
* Tu lai dau tu von
gen income_dautu = m4dc2_17
label var income_dautu "Thu nhap tu lai dau tu von (12 thang)"

* Tu qua tang
egen income_quatang = rsum(m4dc2_01 m4dc2_02 m4dc2_03 m4dc2_04 m4dc2_05 m4dc2_06 m4dc2_07 m4dc2_08 m4dc2_09 m4dc2_10 m4dc2_11 m4dc2_12)
label var income_quatang "Thu nhap tu qua tang (12 thang)"

* Tu chuyen nhuong von, chung khoan: khong co
* Tu chuyen nhuong BDS: khong co
* Tu trung thuong: khong co
* Tu ban quyen: khong co
* Tu nhuong quyen thuong mai: khong co
* Tu thua ke: khong co 
* NOTE: trong data con co khoan thu tu cho thue va thu khac (assume: khong su dung de tinh thue trong bai nay)

* Tong thu nhap khac
egen incomekhactotal = rsum(m4dc2_01 m4dc2_02 m4dc2_03 m4dc2_04 m4dc2_05 m4dc2_06 m4dc2_07 m4dc2_08 m4dc2_09 m4dc2_10 ///
											m4dc2_11 m4dc2_12 m4dc2_13 m4dc2_14 m4dc2_15 m4dc2_16 m4dc2_17 m4dc2_18 m4dc2_19 m4dc2_20)
label var incomekhactotal "Thu nhap khac (12 thang)"

 * Merge voi cac thu nhap con lai
gen double idho = xa*10^7 + diaban*10^4 + hoso*10^2
drop if idho == .
order idho , first
keep idho income_dautu income_quatang incomekhactotal
merge m:m idho using "thunhap.dta", gen(merge_khac)
save "thunhap.dta", replace

***************   1.1.4. Tong hop thu nhap   **************
* Lay thong tin quan he gia dinh (Muc 1A) 
 // Tao id de merge voi file khac //
clear
use "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\Muc1A.dta"
gen double id = xa*10^7 + diaban*10^4 + hoso*10^2 + matv                                          
drop if id ==. 
gen double iddad = xa*10^7 + diaban*10^4 + hoso*10^2 + m1ac7a                   
label var iddad "Ma cua bo"
gen double idmom = xa*10^7 + diaban*10^4 + hoso*10^2 + m1ac7b                                   
label var idmom "Ma cua me"
gen double idncs = xa*10^7 + diaban*10^4 + hoso*10^2 + m1ac7c                                   
label var idncs "Ma cua nguoi cham soc"

// Rename cho de call //
rename (m1ac2 m1ac3 m1ac4a m1ac4b) (sex hhrelat biMonth biYear)
replace biMonth = 1 if biMonth < 0
keep id iddad idmom idncs sex hhrelat biMonth biYear

// Merge voi thu nhap //
save "datatonghop.dta", replace
merge m:m id using "thunhap.dta", gen(merge_bio) // missing mot so quan sat thu nhap voi age tu 0-5 // 
replace idho = floor(id / 100) * 100 if idho ==.
save "datatonghop.dta", replace

* Thu nhap tu tien luong tien cong : income1 

* Thu nhap tu kinh doanh : income2 
// Gan thu nhap tu kinh doanh cho chu ho //
gen income2 = 0
replace income2 = incomekdtotal if hhrelat == 1
label var income2 "Thu nhap tu kinh doanh (1 thang)" 
gen income2T = 0
replace income2T = incomekdho if hhrelat == 1
label var income2T "Thu nhap tu kinh doanh phai chiu thue (1 thang)"
replace income1T = 0
replace income1 = 0

* Tong thu nhap tu tien luong va kinh doanh : income1 + income2
egen income = rsum(income1 income2)
label var income "Thu nhap tu tien luong + kinh doanh (1 thang)" 
egen incomeT = rsum(income1T income2T)
label var incomeT "Thu nhap tu tien luong + kinh doanh chiu thue (1 thang)"

* Thu nhap khac : income3
// Gan thu nhap khac cho chu ho //
gen income3 = 0 
replace income3 = incomekhactotal / 12 if hhrelat == 1
label var income3 "Thu nhap khac (1 thang)" 
// NOTE: chiu thue gom income_dautu + income_quatang  //
replace income_dautu = 0 if hhrelat != 1
replace income_quatang = 0 if hhrelat != 1

save "datatonghop.dta", replace
*---------------------------------------------------------------------*
*------------- 1.2. CAC KHOAN GIAM TRU ------------*
*---------------------------------------------------------------------*

* Giam tru gia canh (nguoi phu thuoc): 3,6 trieu/thang/nguoi
* i. Con duoi 18 tuoi																										// Xac dinh duoc
* ii. Con 18 tuoi tro len bi khuyet tat																					// Khong xac dinh duoc
* iii. Con 18 tuoi tro len dang di hoc dai hoc/cao dang/nghe + thu nhap < 1 trieu/thang			// Xac dinh duoc
* iv. Vo/chong, anh/chi/em, cha/me, nguoi than khac trong do tuoi lao dong + khuyet tat + thu nhap < 1 trieu/thang				// Khong xac dinh duoc
* iv. Vo/chong, anh/chi/em, cha/me, nguoi than khac ngoai do tuoi lao dong + thu nhap < 1 trieu/thang									// Xac dinh duoc
* Giam tru nguoi nop thue: 9 trieu/thang	

**********    1.2.1. Xac dinh con cai phu thuoc  *********
* Lay thong tin giao duc
clear
use "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\Muc2A.dta"
gen double id = xa*10^7 + diaban*10^4 + hoso*10^2 + matv                                          
drop if id ==. 
order id, first
rename m2ac6 curEdu
keep id curEdu

// Merge giao duc vao file tong hop //
save "giaoduc.dta", replace
use "datatonghop.dta"
merge 1:1 id using "giaoduc.dta", gen(merge_edu)

* Xac dinh con cai phu thuoc

// Tinh tuoi theo thang den 12/2014 //
gen realbiYear = biYear + biMonth / 12
label var realbiYear "year of birth"
gen age = 2015 - realbiYear
label var age "Age" 

// Xac dinh con de duoi 18 tuoi //
gen depChild = (age <18) 
label var depChild "Nguoi duoi 18 tuoi"

// Xac dinh con de tren 18 tuoi dang di hoc, thu nhap < 1 trieu/thang //
//---- curEdu: 	0. mau giao, 1. tieu hoc, 2. THCS, 3. THPT, 4. So cap nghe, 5. Trung cap nghe, 6. Trung hoc chuyen nghiep, 7. Cao dang nghe
//---------------	8. cao dang, 9. Dai hoc, 10. Thac si, 11. Tien si, 12. Khac
gen depTeen = (age>=18) & (curEdu >= 4 & curEdu <= 9) & (income < 1000 | income == .)  
label var depTeen "Nguoi dang di hoc"


**********    1.2.2. Xac dinh thanh vien khac (vo chong/cha me) phu thuoc   *********

* Xac dinh thanh vien gia dinh ngoai tuoi lao dong (nam: 60, nu: 55), thu nhap < 1 trieu/thang //
//---- sex: 1. Nam, 2. Nu
gen depOld = ((sex == 1 & age > 60) | (sex == 2 & age >55)) & (income < 1000 | income == .) 
label var depOld "Nguoi gia khong thu nhap" 

* Nguoi khuyet tat : chua xac dinh duoc

**********************    1.2.3. Tong hop so nguoi phu thuoc   *****************

* So nguoi phu thuoc trong ho

// NOTE: Su dung so tre em va hoc sinh de tinh nguoi phu thuoc, tranh overestimate  // 
// NOTE: khong xu ly duoc tinh trang di o nha nguoi quen ->  quan he khac khong tinh phu thuoc 
gen dep = (depChild ==1) | (depTeen ==1)  & hhrelat != 7
label var dep "Nguoi co the xet phu thuoc (tre em + hssv)"
bysort tinh huyen xa diaban hoso: egen hhdep = sum(dep)
label var hhdep "So nguoi phu thuoc trong ho"

* Thu tu thu nhap cao -> thap trong ho
// 2 dong nay phai di cung nhau theo dung thu tu //
gsort tinh huyen xa diaban hoso -income
bysort tinh huyen xa diaban hoso: gen thutuincome = _n

* Phan bo nguoi phu thuoc de thoa man khac biet ve so nguoi phu thuoc can de khong phai nop thue < 2 //

// Tinh so nguoi phu thuoc can de thu nhap duoi muc nop thue //
//------NOTE: 9 trieu + 3,6tr/nguoi phu thuoc //
gen depReq = ceil((income - 9000) / 3600)
replace depReq = 0 if depReq < 0 

// Phan bo nguoi phu thuoc //
//---- Cach phan bo chinh xac tuong doi: Phan bo cho nguoi co thu nhap cao nhat truoc
gen pitdep = hhdep if depReq > hhdep & depReq > 0 & thutuincome == 1 
replace pitdep = depReq if depReq <= hhdep & depReq > 0 & thutuincome == 1 
label var pitdep "So nguoi phu thuoc de tinh PIT" 

//---- Phan con lai phan bo cho nguoi cao thu 2 //
by tinh huyen xa diaban hoso: egen daphanbo = sum(pitdep)
gen chuaphanbo = hhdep - daphanbo
replace pitdep = chuaphanbo if depReq > chuaphanbo & depReq > 0 & thutuincome == 2
replace pitdep = depReq if depReq <= chuaphanbo & depReq > 0 & thutuincome == 2
drop daphanbo chuaphanbo

//---- Phan con lai phan bo cho nguoi cao thu 3 //
by tinh huyen xa diaban hoso: egen daphanbo = sum(pitdep)
gen chuaphanbo = hhdep - daphanbo
replace pitdep = chuaphanbo if depReq > chuaphanbo & depReq > 0 & thutuincome == 3
replace pitdep = depReq if depReq <= chuaphanbo & depReq > 0 & thutuincome == 3
drop daphanbo chuaphanbo depReq thutuincome

*---------------------------------------------------------------------*
*--------------------- 1.3. TINH THUE TNCN -----------------------*
*---------------------------------------------------------------------*

*--------------   1.3.1. Tinh thue tu tien luong + thu nhap tu kinh doanh --------------*
* Thu nhap chiu thue = income - 9tr - 3,6tr * so nguoi phu thuoc
gen income_taxed = incomeT - 9000 - 3600*pitdep if income > 9000
recode income_taxed . = 0
label var income_taxed "Thu nhap chiu thue (thang)"

* Ap dung bieu thue suat 

// Xac dinh bac thue suat //
gen 			pitLevel = 1 if income_taxed <= 5000 & income_taxed > 0	//5%
replace 	pitLevel = 2 if income_taxed > 5000			//10%
replace 	pitLevel = 3 if income_taxed > 10000		//15%
replace 	pitLevel = 4 if income_taxed > 18000		//20%
replace 	pitLevel = 5 if income_taxed > 32000		//25%
replace 	pitLevel = 6 if income_taxed > 52000		//30%
replace 	pitLevel = 7 if income_taxed > 80000		//35%
label var pitLevel "Bac thue TNCN"

// Tinh thue theo thang // 
gen 			pit = 					(income_taxed - 0)			* 0.05	if pitLevel == 1 
replace 	pit = 250 		+		(income_taxed - 5000) 	* 0.10 	if pitLevel == 2
replace 	pit = 750 		+		(income_taxed - 10000)  * 0.15	if pitLevel == 3
replace 	pit = 1950 	+		(income_taxed - 18000)  * 0.20 	if pitLevel == 4
replace 	pit = 4750 	+		(income_taxed - 32000)  * 0.25	if pitLevel == 5
replace 	pit = 9750 	+		(income_taxed - 52000)  * 0.30 	if pitLevel == 6
replace 	pit = 18150 	+		(income_taxed - 80000) 	* 0.35 	if pitLevel == 7
recode pit . = 0
label var pit "Thue thu nhap ca nhan tu tien luong + kinh doanh (1 thang)"

// Tinh thue phai nop trong nam di lam //
// NOTE: lay tam thoi gian la 12 thang - dang nhe phai lay thoi gian lam viec thuc te //
gen pitYear_luongkd = pit * 12
label var pitYear_luongkd "Thue thu nhap ca nhan tu tien luong + kinh doanh (12 thang)" 

*--------------   1.3.2. Tinh thue TNCN tu thu nhap khac --------------*

* Thu nhap tu dau tu von
//----- NOTE: 1. Khong tach duoc lai suat tien gui NH (khong tinh thue) 
//---------------  2. Khong tach duoc cac khoan cho vay ca nhan (khong thu duoc thue)
//----- Assume la thu duoc het

gen pitYear_dautu = income_dautu * 5 / 100  
recode pitYear_dautu . = 0
label var pitYear_dautu "Thue TNCN tu lai suat dau tu von (12 thang)"

* Thu nhap tu qua tang
//----- NOTE: 1. tren 10 trieu moi lan nhan moi chiu thue + khong co data moi lan nhan 
//--------------  --> tinh theo dieu kien moi thang tren 10 trieu (khong duoc) 
//--------------   2. Khong tach duoc cac khoan bieu tang khong thu duoc thue 
gen income_quatang_thang  = income_quatang / 12
gen pitYear_quatang = income_quatang * 10 / 100 if income_quatang > 120000
recode pitYear_quatang . = 0
label var pitYear_quatang "Thue TNCN tu qua tang (12 thang)"

*--------------- 1.3.3. Tong thue TNCN ----------------*
egen pitYearTotal = rsum(pitYear_luongkd pitYear_dautu pitYear_quatang)
label var pitYearTotal "Tong thu thue TNCN ca nam"
* Ghep quyen so
save "datatonghop.dta", replace

clear
use "D:\VHLSS_all\VHLSS2014\VHLSS 2014\VHLSS2014_Households\ttchung.dta"
gen double idho = xa*10^7 + diaban*10^4 + hoso*10^2                                   
keep idho wt9
merge m:m idho using "datatonghop.dta", gen(merge_w) keep(match using)
replace wt9 = 0 if merge_w == 2  // khong co quyen so
save "datatonghop.dta", replace

* Tinh doanh thu thue TNCN theo thang
tabstat pitYearTotal [fw=wt9], s(sum) format("%12.0f")

