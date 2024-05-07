// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:hiremitest/intern_job_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

class InternScreen extends StatefulWidget {
  const InternScreen({super.key});

  @override
  State<InternScreen> createState() => _InternScreenState();
}

class _InternScreenState extends State<InternScreen> {
  List<InternshipJobModel> InternshipList = [];
  Map<int, bool> jobStatusMap = {};

  List<int> appliedJobIds = [];
  List<int> otherJobIds = [];
  String loginEmail = "";
  bool AlreadyApplied = false;
  bool alreadyApplied = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // OnlyApplyOneJob();
    fetchDataFromApi();
    //_loadUserEmail();
    //_checkAppliedJobs(); //
    //checkIfApplied();
    //_loadStatus2();
    //fetchAppliedJobs();
  }

  // Future<void> _loadUserEmail() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? savedUsername = prefs.getString('username');

  //   if (savedUsername != null && savedUsername.isNotEmpty) {
  //     setState(() {
  //       loginEmail = savedUsername;
  //     });
  //     print("login mail is  $loginEmail");
  //   }
  // }

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get(Uri.parse('${ApiUrls.baseurl}/api/internship/'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        InternshipList = responseData
            .map((data) => InternshipJobModel.fromJson(data))
            .toList();
        isLoading = false;
      });
      print("internship List Length: ${InternshipList.length}");
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> OnlyApplyOneJob() async {
    print("OnlyApplyOneJob");
    try {
      final response = await http
          .get(Uri.parse('${ApiUrls.baseurl}Internship-applications/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        // Counter for verified records

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];

          final String userEmail = data['email'];

          if (userEmail == loginEmail) {
            await OnlyApplyOneJobDialogBox();
            print("I am in if section");
            break;
            // Increment the counter for the next verified record
          } else {
            print("Hello i am in else section");
            print(loginEmail);
          }
        }
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in OnlyApplyOneJob :$e");
    }
  }

  Future<bool> checkIfApplied(
      String userEmail, String InternshipProfile, String companyName) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiUrls.baseurl}Internship-applications/'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);

        for (int index = 0; index < dataList.length; index++) {
          final Map<String, dynamic> data = dataList[index];
          final String appliedUserEmail = data['email'];
          final String appliedInternshipProfile = data['Internship_profile'];
          final String appliedCompanyName = data['company_name'];

          if (appliedUserEmail == userEmail &&
              appliedInternshipProfile == InternshipProfile &&
              appliedCompanyName == companyName) {
            return true;
          }
        }
        return false; // User hasn't applied for this job
      } else {
        print('Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error in checkIfApplied: $e");
      return false;
    }
  }

  Future<bool> OnlyApplyOneJobDialogBox() async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            actions: [
              Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Center(
                    child: Text(
                      "Your can only apply one internship",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "FontMain",
                        fontSize: 18,
                        color: Color(0xFFBD232B),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Handle onTap
                      // var sharedPref=await SharedPreferences.getInstance();
                      // sharedPref.setBool(CongratulationScreenState.KEYLOGIN, false);
                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const HomePage(
                      //           sourceScreen: '',
                      //           uid: '',
                      //           username: '',
                      //           verificationId: '')),
                      //   (Route<dynamic> route) =>
                      //       false, // This line removes all routes from the stack
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF13640),
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "HomePage",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ??
        false; // Return false if the dialog is dismissed without pressing 'OK'
  }

  @override
  Widget build(BuildContext context) {
    print('Applied Job IDs: $appliedJobIds');
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await fetchDataFromApi();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return const HomePage(
                    //         sourceScreen: '',
                    //         uid: '',
                    //         username: '',
                    //         verificationId: '',
                    //       );
                    //     },
                    //   ),
                    // );
                  },
                  child: Image.asset('assets/images/Back_Button.png'),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    const Text(
                      "Internships",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "FontMain",
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Image.asset(
                      'assets/images/Saly-1 (2).png',
                      width: 180,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (InternshipList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 75.0),
                          child: Center(
                            child: Text(
                              'No vacancies are available',
                              style: TextStyle(
                                fontFamily: 'FontMain',
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: 380,
                          height: 620,
                          child: ListView.builder(
                            itemCount: InternshipList.length,
                            itemBuilder: (BuildContext context, int index) {
                              final internship = InternshipList[index];
                              return Column(
                                children: [
                                  Card(
                                    color: const Color(0xFFF8F8F8),
                                    surfaceTintColor: Colors.transparent,
                                    elevation: 3.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'Company: ${internship.companyName}',
                                            style: const TextStyle(
                                              fontFamily: 'FontMain',
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Location: ${internship.InternshipLocation}',
                                            style: const TextStyle(
                                              fontFamily: 'FontMain',
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'CTC: ${internship.InternshipCtc} LPA',
                                            style: const TextStyle(
                                              fontFamily: 'FontMain',
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 200.0),
                                          child: SizedBox(
                                            width: 155,
                                            height: 40,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty
                                                        .all<Color>(const Color(
                                                            0xFFBD232B)),
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(Colors.white),
                                              ),
                                              onPressed: () async {
                                                print("Hello");
                                                bool applied =
                                                    await checkIfApplied(
                                                        loginEmail,
                                                        internship
                                                            .InternshipProfile!,
                                                        internship
                                                            .companyName!);

                                                if (applied) {
                                                  print("Applied");
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'You have already applied for this internship.'),
                                                    ),
                                                  );
                                                } else {
                                                  print("Not Applied");
                                                  final int jobIndex =
                                                      InternshipList.indexOf(
                                                          internship);
                                                  print(
                                                      "Selected Job Index: $jobIndex");
                                                  //   Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           InternshipDescription(
                                                  //         jobIndex: jobIndex,
                                                  //         id: internship.id!,
                                                  //         InternshipProfile:
                                                  //             internship
                                                  //                 .InternshipProfile!,
                                                  //         InternshipLocation:
                                                  //             internship
                                                  //                 .InternshipLocation!,
                                                  //         InternshipCtc:
                                                  //             internship
                                                  //                 .InternshipCtc!,
                                                  //         companyName: internship
                                                  //             .companyName!,
                                                  //         education: internship
                                                  //             .education!,
                                                  //         InternshipDescreption:
                                                  //             internship
                                                  //                 .InternshipDescription!,
                                                  //         termsAndConditions:
                                                  //             internship
                                                  //                 .termsAndConditions!,
                                                  //         skillRequired: internship
                                                  //             .skillsRequired!,
                                                  //       ),
                                                  //     ),
                                                  //   );
                                                }
                                              },
                                              child: const Row(
                                                children: [
                                                  Text(
                                                    'View details',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 73,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
