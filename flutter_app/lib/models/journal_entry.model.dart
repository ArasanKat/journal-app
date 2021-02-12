
class JournalEntry {
  String content;
  DateTime dateCreated;
  double score;
  double magnitude;

  JournalEntry(this.content, this.dateCreated, this.score, this.magnitude) {
    content = this.content;
    dateCreated = this.dateCreated;
    score = this.score;
    magnitude = this.magnitude;
  }
}