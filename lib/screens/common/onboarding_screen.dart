import 'package:depanini/screens/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  bool isOnLastPage = false;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged:
                (index) => setState(() {
                  isOnLastPage = (index == 2);
                }),
            children: [
              const OnBoardingPage(
                image: 'assets/images/onBoarding_1.png',
                title: 'Experts à Votre Service',
                subTitle:
                    'Trouvez rapidement des experts fiables pour vos besoins quotidiens.',
              ),
              const OnBoardingPage(
                image: 'assets/images/onBoarding_2.png',
                title: 'Rapide et Efficace',
                subTitle:
                    'Choisissez un service, réservez, et laissez nos experts s\'occuper du reste.',
              ),
              const OnBoardingPage(
                image: 'assets/images/onBoarding_3.png',
                title: 'Votre Satisfaction, Notre Priorité',
                subTitle:
                    'Des experts qualifiés, une assistance rapide et des résultats fiables pour tous vos besoins.',
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 10,
            child: TextButton(
              onPressed: () {
                pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                // pageController.jumpToPage(2);
              },
              child: Text(
                'Skip',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Container(
            alignment: const Alignment(0, 0.7),
            child: SmoothPageIndicator(
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotHeight: 10,
                dotWidth: 10,
                spacing: 5,
              ),
              onDotClicked: (index) {
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              controller: pageController,
            ),
          ),
          Container(
            alignment: const Alignment(0, 0.85),
            child:
                isOnLastPage
                    ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SigninScreen(),
                          ),
                        );
                      },
                      child: const Text('Commencer maintenant!'),
                    )
                    : ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text('Suivant'),
                    ),
          ),
        ],
      ),
    );
  }
}

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  final String image, title, subTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image(
            image: AssetImage(image),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          Text(
            textAlign: TextAlign.center,
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            subTitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
