import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum FigmaSymbol {
  home('24-2171-icone-house24-px66.svg'),
  homeActive('24-2170-icone-house24-px9.svg'),
  agenda('24-2170-icone-calendar-days24-px51.svg'),
  agendaActive('24-2171-icone-calendar-days24-px10.svg'),
  care('24-2170-icone-heart24-px52.svg'),
  careActive('24-2173-icone-heart24-px11.svg'),
  profile('24-2170-icone-user-round24-px53.svg'),
  profileActive('24-2174-icone-user-round24-px12.svg'),
  sun('24-2170-icone-sun24-px64.svg'),
  calendar('24-2170-icone-calendar-days20-px2.svg'),
  heart('24-2170-icone-heart24-px3.svg'),
  chevron('24-2170-icone-chevron-right20-px4.svg'),
  plus('24-2170-icone-plus20-px25.svg'),
  success('24-2170-icone-circle-check20-px37.svg'),
  appointment('24-2171-plus.svg'),
  clock('24-2172-icone-clock20-px43.svg'),
  dateField('24-2172-icone-calendar-days20-px42.svg'),
  pencil('24-2172-icone-pencil20-px34.svg'),
  dropdown('24-2172-icone-chevron-down20-px45.svg'),
  save('24-2172-plus.svg'),
  cancel('24-2172-arrow-right.svg'),
  careButton('24-2173-plus1.svg'),
  editMoment('24-2173-plus.svg'),
  accessibility('24-2174-icone-accessibility24-px68.svg'),
  profileChevron('24-2174-icone-chevron-right20-px69.svg'),
  editProfile('24-2174-plus.svg');

  const FigmaSymbol(this.file);
  final String file;
  double get dimension => file.contains('24-px') ? 24 : 20;
}

/// Intrinsic SVG dimensions are preserved; touch targets belong to the control.
class FigmaIcon extends StatelessWidget {
  const FigmaIcon(this.symbol, {super.key});
  final FigmaSymbol symbol;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox(
        width: symbol.dimension,
        height: symbol.dimension,
        child: SvgPicture.asset('assets/icons/figma/${symbol.file}'),
      ),
    ),
  );
}
