import 'package:flutter/material.dart';


class PrivacyPolicy extends StatelessWidget {
final String privacy = """Your privacy is important to us. It is Juggle's policy to respect your privacy regarding any information we may collect from you through our app, FlashChat.\n
We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we’re collecting it and how it will be used.\n
We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.\n
We don’t share any personally identifying information publicly or with third-parties, except when required to by law.\n
Our app may link to external sites that are not operated by us. Please be aware that we have no control over the content and practices of these sites, and cannot accept responsibility or liability for their respective privacy policies.\n
You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.\n
Your continued use of our website will be regarded as acceptance of our practices around privacy and personal information. If you have any questions about how we handle user data and personal information, feel free to contact us.\n
This policy is effective as of 11 December 2019.
""";

final String termsOfService = """1. Terms
By accessing our app, FlashChat, you are agreeing to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing FlashChat. The materials contained in FlashChat are protected by applicable copyright and trademark law.\n
2. Use License
  a) Permission is granted to temporarily download one copy of FlashChat per device for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:
  i) modify or copy the materials;
  ii) use the materials for any commercial purpose, or for any public display (commercial or non-commercial);
  iii) attempt to decompile or reverse engineer any software contained in FlashChat;
  iv) remove any copyright or other proprietary notations from the materials; or
  v) transfer the materials to another person or "mirror" the materials on any other server.
  b) This license shall automatically terminate if you violate any of these restrictions and may be terminated by Juggle at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format.\n
3. Disclaimer
The materials within FlashChat are provided on an 'as is' basis. Juggle makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.
Further, Juggle does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its website or otherwise relating to such materials or on any sites linked to FlashChat.\n
4. Limitations
In no event shall Juggle or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use FlashChat, even if Juggle or a Juggle authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.\n
5. Accuracy of materials
The materials appearing in FlashChat could include technical, typographical, or photographic errors. Juggle does not warrant that any of the materials on FlashChat are accurate, complete or current. Juggle may make changes to the materials contained in FlashChat at any time without notice. However Juggle does not make any commitment to update the materials.\n
6. Links
Juggle has not reviewed all of the sites linked to its app and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Juggle of the site. Use of any such linked website is at the user's own risk.\n
7. Modifications
Juggle may revise these terms of service for its app at any time without notice. By using FlashChat you are agreeing to be bound by the then current version of these terms of service.\n
8. Governing Law
These terms and conditions are governed by and construed in accordance with the laws of Delhi, India and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy & TOS'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[
             Text("Privacy Policy", style: TextStyle(
               fontSize: 19,
               fontWeight: FontWeight.bold,
             ),),
             SizedBox(height: MediaQuery.of(context).size.height*0.008),
             Text(privacy),
             SizedBox(height: MediaQuery.of(context).size.height*0.04),
             Text("Terms of Service", style: TextStyle(
               fontSize: 19,
               fontWeight: FontWeight.bold
             ),),
             SizedBox(height: MediaQuery.of(context).size.height*0.008),
             Text(termsOfService),
           ],
          ),
        ),
      ),
    );
  }
}