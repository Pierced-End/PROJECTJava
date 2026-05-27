package com.sudoku;

import java.util.Random;

public class SudokuGenerator {
    private static final int SIZE = 9;
    private static final int BOX_SIZE = 3;
    private Random random;
    
    public SudokuGenerator() {
        this.random = new Random();
    }
    
    public int[][] generatePuzzle(int clues) {
        int[][] solution = generateFullGrid();
        int[][] puzzle = new int[SIZE][SIZE];
        
        for (int i = 0; i < SIZE; i++) {
            System.arraycopy(solution[i], 0, puzzle[i], 0, SIZE);
        }
        
        int cellsToRemove = SIZE * SIZE - clues;
        while (cellsToRemove > 0) {
            int row = random.nextInt(SIZE);
            int col = random.nextInt(SIZE);
            if (puzzle[row][col] != 0) {
                puzzle[row][col] = 0;
                cellsToRemove--;
            }
        }
        
        return puzzle;
    }
    
    private int[][] generateFullGrid() {
        int[][] grid = new int[SIZE][SIZE];
        
        // Fill diagonal boxes first (they don't affect each other)
        fillDiagonalBoxes(grid);
        
        // Fill the rest
        solveRemaining(grid, 0, BOX_SIZE);
        
        return grid;
    }
    
    private void fillDiagonalBoxes(int[][] grid) {
        for (int box = 0; box < SIZE; box += BOX_SIZE) {
            fillBox(grid, box, box);
        }
    }
    
    private void fillBox(int[][] grid, int row, int col) {
        int[] nums = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        shuffle(nums);
        int index = 0;
        for (int i = 0; i < BOX_SIZE; i++) {
            for (int j = 0; j < BOX_SIZE; j++) {
                grid[row + i][col + j] = nums[index++];
            }
        }
    }
    
    private boolean solveRemaining(int[][] grid, int row, int col) {
        if (col >= SIZE) {
            row++;
            col = 0;
        }
        if (row >= SIZE) {
            return true;
        }
        
        // Skip diagonal boxes (already filled)
        if (row / BOX_SIZE == col / BOX_SIZE) {
            return solveRemaining(grid, row, col + 1);
        }
        
        int[] nums = {1, 2, 3, 4, 5, 6, 7, 8, 9};
        shuffle(nums);
        
        for (int num : nums) {
            if (isSafe(grid, row, col, num)) {
                grid[row][col] = num;
                if (solveRemaining(grid, row, col + 1)) {
                    return true;
                }
                grid[row][col] = 0;
            }
        }
        return false;
    }
    
    private boolean isSafe(int[][] grid, int row, int col, int num) {
        // Check row
        for (int x = 0; x < SIZE; x++) {
            if (grid[row][x] == num) {
                return false;
            }
        }
        
        // Check column
        for (int x = 0; x < SIZE; x++) {
            if (grid[x][col] == num) {
                return false;
            }
        }
        
        // Check box
        int boxRow = row - row % BOX_SIZE;
        int boxCol = col - col % BOX_SIZE;
        for (int i = 0; i < BOX_SIZE; i++) {
            for (int j = 0; j < BOX_SIZE; j++) {
                if (grid[boxRow + i][boxCol + j] == num) {
                    return false;
                }
            }
        }
        return true;
    }
    
    private void shuffle(int[] array) {
        for (int i = array.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }
}