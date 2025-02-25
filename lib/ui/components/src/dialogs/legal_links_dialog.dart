part of components;

/// A dialog containing legal links.
class _LegalLinksDialog extends StatelessWidget {
  /// A dialog containing legal links.
  const _LegalLinksDialog({Key? key}) : super(key: key);

  static const List<_LegalLink> _legalLinks = [
    _LegalLink(
      text: "Politique de confidentialité",
      url: "https://ynotes.fr/legal/CGUYNotes.pdf",
    ),
    _LegalLink(text: "Conditions d'utilisation", url: "https://ynotes.fr/legal/CGUYNotes.pdf")
  ];

  @override
  Widget build(BuildContext context) {
    return YDialogBase(
      title: 'Mentions légales',
      body: Column(children: [
        for (final link in _legalLinks)
          YButton(
              text: link.text,
              onPressed: () => launch(link.url),
              block: true,
              color: YColor.secondary,
              invertColors: true,
              variant: YButtonVariant.text),
      ]),
      actions: [YButton(text: "FERMER", onPressed: () => Navigator.pop(context))],
    );
  }
}

class _LegalLink {
  final String text;
  final String url;

  const _LegalLink({required this.text, required this.url});
}
