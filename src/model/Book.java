package model;

import java.sql.Timestamp;

public class Book {
    private int bookId;
    private String title;
    private String author;
    private String isbn;
    private String category;
    private String publisher;
    private int publicationYear;
    private int totalCopies;
    private int availableCopies;
    private String description;
    private String coverImage;
    private Timestamp addedDate;
    private Timestamp lastUpdated;
    private int addedBy;

    // Constructor for creating new book
    public Book(String title, String author, String isbn, String category, 
                String publisher, int publicationYear, int totalCopies, String description) {
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.category = category;
        this.publisher = publisher;
        this.publicationYear = publicationYear;
        this.totalCopies = totalCopies;
        this.availableCopies = totalCopies;
        this.description = description;
    }

    // Constructor for retrieving from database
    public Book(int bookId, String title, String author, String isbn, String category, 
                String publisher, int publicationYear, int totalCopies, int availableCopies, 
                String description, String coverImage, Timestamp addedDate, Timestamp lastUpdated, int addedBy) {
        this.bookId = bookId;
        this.title = title;
        this.author = author;
        this.isbn = isbn;
        this.category = category;
        this.publisher = publisher;
        this.publicationYear = publicationYear;
        this.totalCopies = totalCopies;
        this.availableCopies = availableCopies;
        this.description = description;
        this.coverImage = coverImage;
        this.addedDate = addedDate;
        this.lastUpdated = lastUpdated;
        this.addedBy = addedBy;
    }

    // Getters
    public int getBookId() { return bookId; }
    public String getTitle() { return title; }
    public String getAuthor() { return author; }
    public String getIsbn() { return isbn; }
    public String getCategory() { return category; }
    public String getPublisher() { return publisher; }
    public int getPublicationYear() { return publicationYear; }
    public int getTotalCopies() { return totalCopies; }
    public int getAvailableCopies() { return availableCopies; }
    public String getDescription() { return description; }
    public String getCoverImage() { return coverImage; }
    public Timestamp getAddedDate() { return addedDate; }
    public Timestamp getLastUpdated() { return lastUpdated; }
    public int getAddedBy() { return addedBy; }

    // Setters
    public void setBookId(int bookId) { this.bookId = bookId; }
    public void setTitle(String title) { this.title = title; }
    public void setAuthor(String author) { this.author = author; }
    public void setIsbn(String isbn) { this.isbn = isbn; }
    public void setCategory(String category) { this.category = category; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public void setPublicationYear(int publicationYear) { this.publicationYear = publicationYear; }
    public void setTotalCopies(int totalCopies) { this.totalCopies = totalCopies; }
    public void setAvailableCopies(int availableCopies) { this.availableCopies = availableCopies; }
    public void setDescription(String description) { this.description = description; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public void setAddedBy(int addedBy) { this.addedBy = addedBy; }

    // Utility methods
    public boolean isAvailable() {
        return availableCopies > 0;
    }

    public int getBorrowedCopies() {
        return totalCopies - availableCopies;
    }

    @Override
    public String toString() {
        return "Book{" +
                "bookId=" + bookId +
                ", title='" + title + '\'' +
                ", author='" + author + '\'' +
                ", isbn='" + isbn + '\'' +
                ", availableCopies=" + availableCopies +
                '}';
    }
}