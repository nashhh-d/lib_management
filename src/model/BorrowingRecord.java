package model;

import java.sql.Date;
import java.math.BigDecimal;

public class BorrowingRecord {
    private int borrowId;
    private int userId;
    private int bookId;
    private Date borrowDate;
    private Date dueDate;
    private Date returnDate;
    private String status; // borrowed, returned, overdue
    private BigDecimal fineAmount;
    private String notes;
    private int issuedBy;
    private int returnedTo;
    
    // Additional fields for joined data
    private String userName;
    private String userEmail;
    private String bookTitle;
    private String bookAuthor;

    // Constructor for creating new borrowing record
    public BorrowingRecord(int userId, int bookId, Date borrowDate, Date dueDate, int issuedBy) {
        this.userId = userId;
        this.bookId = bookId;
        this.borrowDate = borrowDate;
        this.dueDate = dueDate;
        this.status = "borrowed";
        this.fineAmount = BigDecimal.ZERO;
        this.issuedBy = issuedBy;
    }

    // Constructor for retrieving from database
    public BorrowingRecord(int borrowId, int userId, int bookId, Date borrowDate, 
                          Date dueDate, Date returnDate, String status, BigDecimal fineAmount, 
                          String notes, int issuedBy, int returnedTo) {
        this.borrowId = borrowId;
        this.userId = userId;
        this.bookId = bookId;
        this.borrowDate = borrowDate;
        this.dueDate = dueDate;
        this.returnDate = returnDate;
        this.status = status;
        this.fineAmount = fineAmount;
        this.notes = notes;
        this.issuedBy = issuedBy;
        this.returnedTo = returnedTo;
    }

    // Getters
    public int getBorrowId() { return borrowId; }
    public int getUserId() { return userId; }
    public int getBookId() { return bookId; }
    public Date getBorrowDate() { return borrowDate; }
    public Date getDueDate() { return dueDate; }
    public Date getReturnDate() { return returnDate; }
    public String getStatus() { return status; }
    public BigDecimal getFineAmount() { return fineAmount; }
    public String getNotes() { return notes; }
    public int getIssuedBy() { return issuedBy; }
    public int getReturnedTo() { return returnedTo; }
    public String getUserName() { return userName; }
    public String getUserEmail() { return userEmail; }
    public String getBookTitle() { return bookTitle; }
    public String getBookAuthor() { return bookAuthor; }

    // Setters
    public void setBorrowId(int borrowId) { this.borrowId = borrowId; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }
    public void setStatus(String status) { this.status = status; }
    public void setFineAmount(BigDecimal fineAmount) { this.fineAmount = fineAmount; }
    public void setNotes(String notes) { this.notes = notes; }
    public void setIssuedBy(int issuedBy) { this.issuedBy = issuedBy; }
    public void setReturnedTo(int returnedTo) { this.returnedTo = returnedTo; }
    public void setUserName(String userName) { this.userName = userName; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }

    // Utility methods
    public boolean isOverdue() {
        if (returnDate != null) return false;
        Date today = new Date(System.currentTimeMillis());
        return dueDate.before(today);
    }

    public long getDaysOverdue() {
        if (!isOverdue()) return 0;
        Date today = new Date(System.currentTimeMillis());
        long diff = today.getTime() - dueDate.getTime();
        return diff / (1000 * 60 * 60 * 24);
    }

    @Override
    public String toString() {
        return "BorrowingRecord{" +
                "borrowId=" + borrowId +
                ", userId=" + userId +
                ", bookId=" + bookId +
                ", borrowDate=" + borrowDate +
                ", dueDate=" + dueDate +
                ", status='" + status + '\'' +
                '}';
    }
}